import Foundation

struct EnvironmentVariables {
    static let baseUrl: String = ProcessInfo.processInfo.environment["BASE_URL"] ?? ""
}
