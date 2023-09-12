import SwiftUI

struct PhraseLabel: View {
    var characterName: String
    var text: String

    var body: some View {
        Text(characterName)
            .font(.custom(FontFamily.Overpass.bold.name, size: 14))
            .foregroundColor(Asset.dark.swiftUIColor)
        + Text(": \(text)")
            .font(.custom(FontFamily.Overpass.regular.name, size: 14))
            .foregroundColor(Asset.dark.swiftUIColor)
    }
}
