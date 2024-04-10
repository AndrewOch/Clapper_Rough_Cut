import Foundation

// MARK: - Script File
struct ScriptFile: Identifiable, Codable, Equatable {
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
        determineScriptBlocks(elements: phrases)
    }

    private mutating func determinePhrases() -> [ScriptBlockElement] {
        let lines = fullText.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isNotEmpty }
        var result: [ScriptBlockElement] = []
        for line in lines {
            if !ScriptFile.isPhrase(line: line) {
                if line.rangeOfCharacter(from: CharacterSet.letters) != nil {
                    result.append(ScriptBlockElement(text: line, type: .action))
                } else {
                    result.append(ScriptBlockElement(text: line, type: .none))
                }
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
                result.append(ScriptBlockElement(character: character, phraseText: phraseText, text: line))
            }
        }
        return result
    }

    private mutating func determineScriptBlocks(elements: [ScriptBlockElement]) {
        self.blocks = []
        var scriptLines: [ScriptBlockElement] = []
        var previousType: ScriptBlockElementType = .none
        for element in elements {
            let type = element.type
            if type != previousType {
                self.blocks.append(ScriptBlock(type: previousType, elements: scriptLines))
                    scriptLines = []
                    previousType = type
            }
            scriptLines.append(element)
        }
    }

    private static func isPhrase(line: String) -> Bool {
        let dialogueRegex = #"^([^\n\s]+[\s]?){1,3}:[^\n]+$"#
        return line.range(of: dialogueRegex, options: .regularExpression) != nil
    }

    static func == (lhs: ScriptFile, rhs: ScriptFile) -> Bool {
        lhs.id == rhs.id
    }

    var allPhrases: [ScriptBlockElement] {
        blocks.filter({ $0.elementsType == .phrase }).flatMap({ $0.elements })
    }

    var allActions: [ScriptBlockElement] {
        blocks.filter({ $0.elementsType == .action }).flatMap({ $0.elements })
    }

    public mutating func setBlockType(id: UUID, type: ScriptBlockElementType) {
        guard let index = blocks.firstIndex(where: { $0.id == id }) else { return }
        let block = blocks[index]
        var updatedElements = [ScriptBlockElement]()
        block.elements.forEach({ element in
            var elem = element
            elem.type = type
            updatedElements.append(elem)
        })
        blocks[index].elements = updatedElements
        blocks[index].elementsType = type
    }
}

// MARK: - Characters
extension ScriptFile {
    public func getCharacterPhrases(character: ScriptCharacter) -> [ScriptBlockElement] {
        var result: [ScriptBlockElement] = []
        for block in blocks {
            guard block.elementsType == .phrase else { continue }
            for phrase in block.elements {
                guard let char = phrase.character else { continue }
                if char == character {
                    result.append(phrase)
                }
            }
        }
        return result
    }

    public mutating func updateCharacter(by id: UUID, with newValue: ScriptCharacter) {
        guard let index = characters.firstIndex(where: { $0.id == id }) else { return }
        characters[index] = newValue

        for i in 0..<blocks.count {
            var updatedElements: [ScriptBlockElement] = []
            for element in blocks[i].elements {
                if let character = element.character, character.id == id {
                    let updatedElement = ScriptBlockElement(character: newValue, phraseText: element.phraseText ?? "", text: element.fullText)
                    updatedElements.append(updatedElement)
                } else {
                    updatedElements.append(element)
                }
            }
            blocks[i].elements = updatedElements
        }
    }

    public mutating func removeCharacter(by id: UUID) {
        removeCharacters(by: [id])
    }

    public mutating func removeCharacters(by ids: [UUID]) {
        var updatedPhrases: [ScriptBlockElement] = []
        let removingCharacters = characters.filter({ char in ids.contains(char.id) })
        characters.removeAll { char in ids.contains(char.id) }
        for phrase in blocks.flatMap({ $0.elements }) {
            if removingCharacters.contains(where: { char in phrase.character == char }) {
                updatedPhrases.append(ScriptBlockElement(text: phrase.fullText, type: .none))
                continue
            }
            updatedPhrases.append(phrase)
        }
        determineScriptBlocks(elements: updatedPhrases)
    }
}

// MARK: - Script Block
struct ScriptBlock: Identifiable, Codable {
    var id = UUID()
    var elementsType: ScriptBlockElementType
    var fullText: String {
        var result: String = .empty
        for element in elements {
            result.append("\n\(element.fullText)")
        }
        return result
    }
    var elements: [ScriptBlockElement]
    
    init(text: String, lines: [String], type: ScriptBlockElementType) {
        self.elementsType = type
        self.elements = []
        for line in lines {
            self.elements.append(ScriptBlockElement(text: line, type: type))
        }
    }

    init(type: ScriptBlockElementType, elements: [ScriptBlockElement]) {
        self.elementsType = type
        self.elements = elements
    }

    static func == (lhs: ScriptBlock, rhs: ScriptBlock) -> Bool {
        lhs.id == rhs.id
    }
}

enum ScriptBlockElementType: Codable {
    case none, phrase, action
}

// MARK: - Script Block Element
struct ScriptBlockElement: Identifiable, Codable, Hashable {
    var id = UUID()
    var fullText: String
    var character: ScriptCharacter?
    var phraseText: String?
    var type: ScriptBlockElementType
    var lastUpdate: Date

    init(text: String, type: ScriptBlockElementType) {
        self.fullText = text
        self.type = type
        self.lastUpdate = Date()
    }

    init(character: ScriptCharacter, phraseText: String, text: String) {
        self.fullText = text
        self.character = character
        self.phraseText = phraseText
        self.type = .phrase
        self.lastUpdate = Date()
    }

    var dictionaryRepresentation: [String: Any] {
        var dict = [String: Any]()
        switch type {
        case .none:
            break
        case .phrase:
            dict["phrase_id"] = id.uuidString
            dict["text"] = fullText
            dict["phrase_text"] = phraseText ?? ""
        case .action:
            dict["action_id"] = id.uuidString
            dict["text"] = fullText
            dict["last_update"] = lastUpdate.timeIntervalSince1970
        }
        return dict
    }
}
