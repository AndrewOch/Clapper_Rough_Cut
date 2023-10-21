import SwiftUI

struct PhraseLabel: View {
    @Environment(\.colorScheme) private var colorScheme
    var characterName: String
    var text: String

    var body: some View {
        Text(characterName)
            .font(.custom(FontFamily.Overpass.bold.name, size: 14))
            .foregroundColor(.contentPrimary(colorScheme))
        + Text(": \(text)")
            .font(.custom(FontFamily.Overpass.regular.name, size: 14))
            .foregroundColor(.contentPrimary(colorScheme))
    }
}
