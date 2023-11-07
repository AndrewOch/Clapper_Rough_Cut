extension String {
    public static let empty = ""
    public static let nilParameter = "--"
    public static let typeText = "public.text"
    public static let typeUUID = "public.uuid"
}

extension String {
    var firstWordCapitalized: String {
        var words = self.components(separatedBy: " ")
        guard let firstWord = words.first?.capitalized else { return self }
        words[0] = firstWord.capitalized
        return words.joined(separator: " ")
    }
}
