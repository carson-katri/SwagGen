import JSONUtilities

public struct Path {

    public let path: String
    public let operations: [Operation]
    public let parameters: [PossibleReference<Parameter>]
}

extension Path: NamedMappable {

    public init(name: String, jsonDictionary: JSONDictionary) throws {
        path = name
        parameters = (jsonDictionary.json(atKeyPath: "parameters")) ?? []

        var mappedOperations: [Operation] = []
        for (key, value) in jsonDictionary {
            if let method = Operation.Method(rawValue: key) {
                if let json = value as? [String: Any] {
                    let operation = try Operation(path: path, method: method, pathParameters: parameters, jsonDictionary: json)
                    mappedOperations.append(operation)
                }
            }
        }
        operations = mappedOperations
    }
}

extension Path: Equatable {
    public static func == (lhs: Path, rhs: Path) -> Bool {
        lhs.path == rhs.path &&
            lhs.operations.count == rhs.operations.count &&
            lhs.operations.allSatisfy { rhs.operations.contains($0) } &&
            lhs.parameters.count == rhs.parameters.count &&
            lhs.parameters.allSatisfy { rhs.parameters.contains($0) }
    }
}
