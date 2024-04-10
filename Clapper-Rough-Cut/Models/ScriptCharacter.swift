import Foundation
import SwiftUI

struct ScriptCharacter: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var description: String
    var color: Color

    init(id: UUID = UUID(), name: String, description: String = "", color: Color = Color.random) {
        self.id = id
        self.name = name
        self.description = description
        self.color = color
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case color
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)

        let colorComponents = color.components()
        let hexColor = String(format: "#%02lX%02lX%02lX", lroundf(Float(colorComponents.red * 255)), lroundf(Float(colorComponents.green * 255)), lroundf(Float(colorComponents.blue * 255)))
        try container.encode(hexColor, forKey: .color)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)

        let hexColor = try container.decode(String.self, forKey: .color)
        color = Color(hex: hexColor) ?? .black
    }

    static func == (lhs: ScriptCharacter, rhs: ScriptCharacter) -> Bool {
        lhs.id == rhs.id
    }
}
