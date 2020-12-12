import JSONUtilities

public class Reference<T: Component> {

    let string: String

    private var _value: T?
    public var value: T {
        guard let value = _value else {
            fatalError("Reference \(string) is unresolved")
        }
        return value
    }

    public let name: String

    public init(_ string: String) {
        self.string = string
        name = string.components(separatedBy: "/").last!
    }

    public convenience init(jsonDictionary: JSONDictionary) throws {
        let string: String = try jsonDictionary.json(atKeyPath: "$ref")
        self.init(string)
    }

    public var component: ComponentObject<T> {
        return ComponentObject(name: name, value: value)
    }

    func resolve(with value: T) {
        _value = value
    }

    func getReferenceComponent(index: Int) -> String? {
        let components = string.components(separatedBy: "/")
        guard components.count > index else { return nil }
        return components[index]
    }

    public var referenceType: String? {
        return getReferenceComponent(index: 2)
    }

    public var referenceName: String? {
        return getReferenceComponent(index: 3)
    }
}

public enum PossibleReference<T: Component>: JSONObjectConvertible {

    case reference(Reference<T>)
    case value(T)

    public var value: T {
        switch self {
        case let .reference(reference): return reference.value
        case let .value(value): return value
        }
    }

    public var name: String? {
        if case let .reference(reference) = self {
            return reference.name
        }
        return nil
    }

    public var swaggerObject: ComponentObject<T>? {
        if case let .reference(reference) = self {
            return reference.component
        }
        return nil
    }

    public init(jsonDictionary: JSONDictionary) throws {
        if let reference: String = jsonDictionary.json(atKeyPath: "$ref") {
            self = .reference(Reference<T>(reference))
        } else {
            self = .value(try T(jsonDictionary: jsonDictionary))
        }
    }
}

extension Reference: Equatable where T: Equatable {
    public static func == (lhs: Reference<T>, rhs: Reference<T>) -> Bool {
        lhs.string == rhs.string &&
            lhs._value == rhs._value
    }
}

extension PossibleReference: Equatable where T: Equatable {
    public static func == (lhs: PossibleReference<T>, rhs: PossibleReference<T>) -> Bool {
        switch lhs {
        case let .reference(lhsRef):
            if case let .reference(rhsRef) = rhs {
                return lhsRef == rhsRef
            }
        case let .value(lhsValue):
            if case let .value(rhsValue) = rhs {
                return lhsValue == rhsValue
            }
        default:
            return false
        }
        return false
    }
}
