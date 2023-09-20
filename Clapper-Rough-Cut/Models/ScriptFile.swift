import Foundation

struct ScriptFile: Identifiable, Codable {
    var id = UUID()
    let url: URL
    var fullText: String
    var characters: [ScriptCharacter]
    var blocks: [ScriptBlock]

    init(url: URL, text: String) {
        self.url = url
        self.blocks = []
        self.characters = []
        self.fullText = text
        let phrases = determinePhrases()
        determineScriptBlocks(phrases: phrases)
    }

    private mutating func determinePhrases() -> [Phrase] {
        let lines = fullText.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isNotEmpty }
        var result: [Phrase] = []
        for line in lines {
            if !ScriptFile.isPhrase(line: line) {
                result.append(Phrase(text: line))
                continue
            }
            var character: ScriptCharacter?
            let components = line.components(separatedBy: ":")
            let characterName = components[0]
            if let char = characters.first(where: { char in char.name == characterName }) {
                character = char
            } else {
                character = ScriptCharacter(name: characterName)
                if let character = character {
                    characters.append(character)
                }
            }
            let phraseText = components[1...].joined()
            if let character = character {
                result.append(Phrase(character: character, phraseText: phraseText, text: line))
            }
        }
        return result
    }

    private mutating func determineScriptBlocks(phrases: [Phrase]) {
        self.blocks = []
        var scriptLines: [Phrase] = []
        var previousIsPhrase = false
        for phrase in phrases {
            let isPhrase = phrase.character != nil
            if isPhrase && !previousIsPhrase {
                    self.blocks.append(ScriptBlock(isDialogue: false, phrases: scriptLines))
                    scriptLines = []
                    previousIsPhrase = true
            }
            if !isPhrase && previousIsPhrase {
                    self.blocks.append(ScriptBlock(isDialogue: true, phrases: scriptLines))
                    scriptLines = []
                    previousIsPhrase = false
            }
            scriptLines.append(phrase)
        }
    }

    private static func isPhrase(line: String) -> Bool {
        let dialogueRegex = #"^([^\n\s]+[\s]?){1,3}:[^\n]+$"#
        return line.range(of: dialogueRegex, options: .regularExpression) != nil
    }

    public func getCharacterPhrases(character: ScriptCharacter) -> [Phrase] {
        var result: [Phrase] = []
        for block in blocks {
            guard block.isDialogue else { continue }
            for phrase in block.phrases {
                guard let char = phrase.character else { continue }
                if char == character {
                    result.append(phrase)
                }
            }
        }
        return result
    }

    public mutating func removeCharacter(by id: UUID) {
        removeCharacters(by: [id])
    }

    public mutating func removeCharacters(by ids: [UUID]) {
        var updatedPhrases: [Phrase] = []
        let removingCharacters = characters.filter({ char in ids.contains(char.id) })
        characters.removeAll { char in ids.contains(char.id) }
        for phrase in blocks.flatMap({ $0.phrases }) {
            if removingCharacters.contains(where: { char in phrase.character == char }) {
                updatedPhrases.append(Phrase(text: phrase.fullText))
                continue
            }
            updatedPhrases.append(phrase)
        }
        determineScriptBlocks(phrases: updatedPhrases)
    }
}

struct ScriptBlock: Identifiable, Codable {
    var id = UUID()
    var isDialogue: Bool
    var fullText: String {
        var result: String = .empty
        for phrase in phrases {
            result.append("\n\(phrase.fullText)")
        }
        return result
    }
    var phrases: [Phrase]

    init(text: String, lines: [String]) {
        self.isDialogue = false
        self.phrases = []
        for line in lines {
            self.phrases.append(Phrase(text: line))
        }
    }

    init(isDialogue: Bool, phrases: [Phrase]) {
        self.isDialogue = isDialogue
        self.phrases = phrases
    }

    static func == (lhs: ScriptBlock, rhs: ScriptBlock) -> Bool {
        lhs.id == rhs.id
    }
}

struct Phrase: Identifiable, Codable {
    var id = UUID()
    var fullText: String
    var character: ScriptCharacter?
    var phraseText: String?

    init(text: String) {
        self.fullText = text
    }

    init(character: ScriptCharacter, phraseText: String, text: String) {
        self.fullText = text
        self.character = character
        self.phraseText = phraseText
    }
}
