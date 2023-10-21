extension DateFormatter {
    static var shortStyle: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = .current
        return formatter
    }

    static var longStyle: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = .current
        return formatter
    }
}
