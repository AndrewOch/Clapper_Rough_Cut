import Foundation
import AVKit

class Formatter {
    static func formatDate(date: Date) -> String {
        return DateFormatter.longStyle.string(from: date)
    }

    static func formatDateShort(date: Date) -> String {
        return DateFormatter.shortStyle.string(from: date)
    }

    static func formatDuration(duration: Double) -> String {
        guard duration.isFinite else { return .empty }
        let hours = Int(duration / 3_600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3_600)) / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
