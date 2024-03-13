import SwiftUI

struct ScriptBlockView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var document: ClapperRoughCutDocument
    @Binding var block: ScriptBlock

    var body: some View {
        let type = block.elementsType
        VStack {
            if type == .phrase {
                VStack {
                    HStack {
                        SystemImage.dialogue.imageView
                            .foregroundColor(Asset.accentLight.swiftUIColor)
                        Spacer()
                    }
                    ForEach(block.elements) { phrase in
                        HStack(spacing: 0) {
                            if let character = phrase.character, let phraseText = phrase.phraseText {
                                PhraseLabel(characterName: character.name,
                                            text: phraseText)
                            }
                            Spacer()
                        }
                        .foregroundColor(.contentPrimary(colorScheme))
                    }
                }
                .padding(.all, 5)
                .background(Color.surfacePrimary(colorScheme))
                .cornerRadius(5)
                .overlay(RoundedRectangle(cornerRadius: 5)
                    .stroke(Asset.accentLight.swiftUIColor, lineWidth: 1))
            } else if type == .action {
                VStack {
                    HStack {
                        SystemImage.photo.imageView
                            .foregroundColor(Asset.accentLight.swiftUIColor)
                        Spacer()
                    }
                    HStack(spacing: 0) {
                        CustomLabel<BodyMediumStyle>(text: block.fullText.trimmingCharacters(in: .whitespacesAndNewlines))
                            .foregroundColor(.contentPrimary(colorScheme))
                        Spacer()
                    }
                    .foregroundColor(.contentPrimary(colorScheme))
                }
                .padding(.all, 5)
                .background(Color.surfacePrimary(colorScheme))
                .cornerRadius(5)
                .overlay(RoundedRectangle(cornerRadius: 5)
                    .stroke(Asset.accentLight.swiftUIColor, lineWidth: 1))
            } else {
                CustomLabel<BodyMediumStyle>(text: block.fullText.trimmingCharacters(in: .whitespacesAndNewlines))
                    .foregroundColor(.contentPrimary(colorScheme))
            }
        }
        .contextMenu(menuItems: {
            Menu(L10n.changeType) {
                Button(action: {
                    document.project.scriptFile?.setBlockType(id: block.id, type: .none)
                }) {
                    Text(L10n.plainText)
                    SystemImage.textJustify.imageView
                }
                Button(action: {
                    document.project.scriptFile?.setBlockType(id: block.id, type: .phrase)
                }) {
                    Text(L10n.dialogue)
                    SystemImage.dialogue.imageView
                }
                Button(action: {
                    document.project.scriptFile?.setBlockType(id: block.id, type: .action)
                }) {
                    Text(L10n.action)
                    SystemImage.photo.imageView
                }
            }
        })
    }
}
