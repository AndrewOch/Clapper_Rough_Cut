extension String {
    public static let empty = ""
}

extension String {
    var firstWordCapitalized: String {
        let words = self.components(separatedBy: " ")
        let capitalizedWords = words.map { word -> String in
            guard let firstChar = word.first else {
                return ""
            }
            let restOfWord = String(word.dropFirst()).lowercased()
            return String(firstChar).uppercased() + restOfWord
        }
        return capitalizedWords.joined(separator: " ")
    }
}
