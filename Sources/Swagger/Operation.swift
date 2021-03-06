import JSONUtilities

public struct Operation {

    public let json: [String: Any]
    public let path: String
    public let method: Method
    public let summary: String?
    public let description: String?
    public let requestBody: PossibleReference<RequestBody>?
    public let pathParameters: [PossibleReference<Parameter>]
    public let operationParameters: [PossibleReference<Parameter>]

    public var parameters: [PossibleReference<Parameter>] {
        return pathParameters.filter { pathParam in
            !operationParameters.contains { $0.value.name == pathParam.value.name }
        } + operationParameters
    }

    public let responses: [OperationResponse]
    public let defaultResponse: PossibleReference<Response>?
    public let deprecated: Bool
    public let identifier: String?
    public let tags: [String]
    public let securityRequirements: [SecurityRequirement]?

    public var generatedIdentifier: String {
        return identifier ?? "\(method)\(path)"
    }

    public enum Method: String {
        case get
        case put
        case post
        case delete
        case options
        case head
        case patch
    }
}

extension Operation {

    public init(path: String, method: Method, pathParameters: [PossibleReference<Parameter>], jsonDictionary: JSONDictionary) throws {
        json = jsonDictionary
        self.path = path
        self.method = method
        self.pathParameters = pathParameters
        if jsonDictionary["parameters"] != nil {
            operationParameters = try jsonDictionary.json(atKeyPath: "parameters")
        } else {
            operationParameters = []
        }
        summary = jsonDictionary.json(atKeyPath: "summary")
        description = jsonDictionary.json(atKeyPath: "description")
        requestBody = jsonDictionary.json(atKeyPath: "requestBody")

        identifier = jsonDictionary.json(atKeyPath: "operationId")
        tags = (jsonDictionary.json(atKeyPath: "tags")) ?? []
        securityRequirements = jsonDictionary.json(atKeyPath: "security")

        let allResponses: [String: PossibleReference<Response>] = try jsonDictionary.json(atKeyPath: "responses")
        var mappedResponses: [OperationResponse] = []
        for (key, response) in allResponses {
            if let statusCode = Int(key) {
                let response = OperationResponse(statusCode: statusCode, response: response)
                mappedResponses.append(response)
            }
        }

        if let defaultResponse = allResponses["default"] {
            self.defaultResponse = defaultResponse
            mappedResponses.append(OperationResponse(statusCode: nil, response: defaultResponse))
        } else {
            defaultResponse = nil
        }

        responses = mappedResponses.sorted {
            let code1 = $0.statusCode
            let code2 = $1.statusCode
            switch (code1, code2) {
            case let (.some(code1), .some(code2)): return code1 < code2
            case (.some, .none): return true
            case (.none, .some): return false
            default: return false
            }
        }

        deprecated = (jsonDictionary.json(atKeyPath: "deprecated")) ?? false
    }
}

extension Operation: Equatable {
    public static func == (lhs: Operation, rhs: Operation) -> Bool {
        lhs.path == rhs.path &&
        lhs.method == rhs.method &&
        lhs.summary == rhs.summary &&
        lhs.description == rhs.description &&
        lhs.requestBody == rhs.requestBody &&
        lhs.pathParameters.count == rhs.pathParameters.count &&
        lhs.pathParameters.allSatisfy { rhs.pathParameters.contains($0) } &&
        lhs.operationParameters.count == rhs.operationParameters.count &&
        lhs.operationParameters.allSatisfy { rhs.operationParameters.contains($0) } &&
        lhs.responses.count == rhs.responses.count &&
        lhs.responses.allSatisfy { rhs.responses.contains($0) } &&
        lhs.defaultResponse == rhs.defaultResponse &&
        lhs.deprecated == rhs.deprecated &&
        lhs.identifier == rhs.identifier &&
        lhs.tags == rhs.tags &&
            (lhs.securityRequirements == rhs.securityRequirements ||
                (lhs.securityRequirements?.allSatisfy { rhs.securityRequirements?.contains($0) ?? false }) ?? false
            )
    }
}
