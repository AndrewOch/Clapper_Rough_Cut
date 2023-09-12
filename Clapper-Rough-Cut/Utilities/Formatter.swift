import Foundation

class Formatter {
    static func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = .current
        return formatter.string(from: date)
    }

    static func formatDuration(duration: Double) -> String {
        let minutes = Int(duration / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
        let formattedDuration = String(format: "%02d:%02d", minutes, seconds)
        return formattedDuration
    }
}
