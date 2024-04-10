import SwiftUI

struct PhraseLabel: View {
    
    var characterName: String
    var text: String
    var characterColor: Color

    var body: some View {
        Text(characterName)
            .font(.custom(FontFamily.NunitoSans.bold.name, size: 14))
            .foregroundColor(characterColor)
        + Text(": \(text)")
            .font(.custom(FontFamily.NunitoSans.regular.name, size: 14))
            .foregroundColor(Asset.contentPrimary.swiftUIColor)
    }
}
