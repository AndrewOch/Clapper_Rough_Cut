extension String {
    public static let empty = ""
    public static let nilParameter = "--"
}

extension String {
    var firstWordCapitalized: String {
        var words = self.components(separatedBy: " ")
        guard let firstWord = words.first?.capitalized else { return self }
        words[0] = firstWord.capitalized
        return words.joined(separator: " ")
    }
}
