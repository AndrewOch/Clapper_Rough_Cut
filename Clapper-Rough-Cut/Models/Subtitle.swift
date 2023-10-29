import Foundation

struct Subtitle: Equatable, Codable, Hashable {
    let text: String
    let startTime: Double
    let endTime: Double
}
