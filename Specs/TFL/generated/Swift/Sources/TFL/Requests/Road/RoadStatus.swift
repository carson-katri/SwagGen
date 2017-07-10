//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation
import JSONUtilities

extension TFL.Road {

    public enum RoadStatus {

      public static let service = APIService<Response>(id: "Road_Status", tag: "Road", method: "GET", path: "/Road/{ids}/Status", hasBody: false)

      public class Request: APIRequest<Response> {

          public struct Options {

              /** Comma-separated list of road identifiers e.g. "A406, A2" or use "all" to ignore id filter (a full list of supported road identifiers can be found at the /Road/ endpoint) */
              public var ids: [String]

              public var dateRangeNullableStartDate: Date?

              public var dateRangeNullableEndDate: Date?

              public init(ids: [String], dateRangeNullableStartDate: Date? = nil, dateRangeNullableEndDate: Date? = nil) {
                  self.ids = ids
                  self.dateRangeNullableStartDate = dateRangeNullableStartDate
                  self.dateRangeNullableEndDate = dateRangeNullableEndDate
              }
          }

          public var options: Options

          public init(options: Options) {
              self.options = options
              super.init(service: RoadStatus.service)
          }

          /// convenience initialiser so an Option doesn't have to be created
          public convenience init(ids: [String], dateRangeNullableStartDate: Date? = nil, dateRangeNullableEndDate: Date? = nil) {
              let options = Options(ids: ids, dateRangeNullableStartDate: dateRangeNullableStartDate, dateRangeNullableEndDate: dateRangeNullableEndDate)
              self.init(options: options)
          }

          public override var path: String {
              return super.path.replacingOccurrences(of: "{" + "ids" + "}", with: "\(self.options.ids.joined(separator: ","))")
          }

          public override var parameters: [String: Any] {
              var params: JSONDictionary = [:]
              if let dateRangeNullableStartDate = options.dateRangeNullableStartDate?.encode() {
                params["dateRangeNullable.startDate"] = dateRangeNullableStartDate
              }
              if let dateRangeNullableEndDate = options.dateRangeNullableEndDate?.encode() {
                params["dateRangeNullable.endDate"] = dateRangeNullableEndDate
              }
              return params
          }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {
            public typealias SuccessType = [RoadCorridor]

            /** OK */
            case success200([RoadCorridor])

            public var success: [RoadCorridor]? {
                switch self {
                case .success200(let response): return response
                }
            }

            public var response: Any {
                switch self {
                case .success200(let response): return response
                }
            }

            public var statusCode: Int {
              switch self {
              case .success200: return 200
              }
            }

            public var successful: Bool {
              switch self {
              case .success200: return true
              }
            }

            public init(statusCode: Int, data: Data) throws {
                switch statusCode {
                case 200: self = try .success200(JSONDecoder.decode(data: data))
                default: throw APIError.unexpectedStatusCode(statusCode: statusCode, data: data)
                }
            }

            public var description: String {
                return "\(statusCode) \(successful ? "success" : "failure")"
            }

            public var debugDescription: String {
                var string = description
                let responseString = "\(response)"
                if responseString != "()" {
                    string += "\n\(responseString)"
                }
                return string
            }
        }
    }
}
