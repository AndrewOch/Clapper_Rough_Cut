import Foundation

class ScriptFile: Identifiable, Codable {
    var id = UUID()
    let url: URL
    var fullText: String
    var blocks: [ScriptBlock]

    init(url: URL, text: String) {
        self.url = url
        self.blocks = []
        let scriptBlocks = text.components(separatedBy: "\n\n")
        for scriptBlock in scriptBlocks {
            let scriptBlock = scriptBlock.trimmingCharacters(in: .whitespacesAndNewlines)
            if scriptBlock.isNotEmpty {
                let lines = scriptBlock.components(separatedBy: "\n")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isNotEmpty }
                let isDialogue = ScriptFile.determineIsDialogue(lines: lines)
                let block = ScriptBlock(isDialogue: isDialogue, text: scriptBlock, lines: lines)
                self.blocks.append(block)
            }
        }
        self.fullText = text
    }

    private static func determineIsDialogue(lines: [String]) -> Bool {
        for line in lines {
            let dialogueRegex = #"^([^\n\s]+[\s]?){1,3}:[^\n]+$"#
            if line.range(of: dialogueRegex, options: .regularExpression) != nil { return true }
        }
        return false
    }
}

class ScriptBlock: Identifiable, Codable {
    var id = UUID()
    var isDialogue: Bool
    var fullText: String
    var phrases: [Phrase]

    init(isDialogue: Bool, text: String, lines: [String]) {
        self.isDialogue = isDialogue
        self.fullText = text
        self.phrases = []
        for line in lines {
            self.phrases.append(Phrase(text: line))
        }
    }

    static func == (lhs: ScriptBlock, rhs: ScriptBlock) -> Bool {
        lhs.id == rhs.id
    }
}

class Phrase: Identifiable, Codable {
    var id = UUID()
    var fullText: String
    var characterName: String
    var phraseText: String

    init(text: String) {
        self.fullText = text
        let components = text.components(separatedBy: ":")
        guard components.count == 2 else {
            self.characterName = components[0]
            self.phraseText = components[1...].joined()
            return
        }
        self.characterName = components[0]
        self.phraseText = components[1]
    }
}
