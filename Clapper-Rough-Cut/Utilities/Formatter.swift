import Foundation

class Formatter {
    static func formatDate(date: Date) -> String {
        return DateFormatter.longStyle.string(from: date)
    }

    static func formatDateShort(date: Date) -> String {
        return DateFormatter.shortStyle.string(from: date)
    }

    static func formatDuration(duration: Double) -> String {
        let minutes = Int(duration / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
        let formattedDuration = String(format: "%02d:%02d", minutes, seconds)
        return formattedDuration
    }
}
