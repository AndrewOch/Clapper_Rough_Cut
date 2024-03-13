import Foundation

struct ScriptCharacter: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var description: String

    init(id: UUID = UUID(), name: String, description: String = .empty) {
        self.id = id
        self.name = name
        self.description = description
    }

    static func == (lhs: ScriptCharacter, rhs: ScriptCharacter) -> Bool {
        lhs.id == rhs.id
    }
}
