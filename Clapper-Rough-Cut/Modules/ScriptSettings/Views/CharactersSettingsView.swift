import SwiftUI

struct CharactersSettingsView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @State var characterPhrases: [UUID: [ScriptBlockElement]]
    @State var closeAction: () -> Void
    @State private var selectedCharacters: [UUID] = []
    @State private var lastSelectedCharacterIndex: Int? = nil
    @State private var commandKeyPressed = false
    @State private var shiftKeyPressed = false

    var body: some View {
        ModalSheet(title: L10n.characters.firstWordCapitalized,
                   minWidth: 600,
                   idealWidth: 800,
                   minHeight: 200,
                   idealHeight: 500,
                   maxHeight: 600,
                   resizableVertical: true) {
            HStack {
                list
                    .frame(minWidth: 150, idealWidth: 300, maxWidth: 300)
                detailed
                    .frame(minWidth: 400, idealWidth: 500, maxWidth: .infinity)
            }
        } closeAction: {
            closeAction()
        }
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { event in
                commandKeyPressed = event.modifierFlags.contains(.command)
                shiftKeyPressed = event.modifierFlags.contains(.shift)
                return event
            }
        }
    }

    private var list: some View {
        VStack {
            if let scriptFile = document.project.scriptFile {
                HStack {
                    CustomLabel<BodyMediumStyle>(text: "\(L10n.charactersInScript.firstWordCapitalized): \(scriptFile.characters.count)")
                        .foregroundColor(Asset.contentPrimary.swiftUIColor)
                    Spacer()
                }.padding(.horizontal, 10)
                VStack {
                    ScrollView {
                        LazyVStack(spacing: 5) {
                            let characters = scriptFile.characters.sorted(by: { char1, char2 in
                                characterPhrases[char1.id]?.count ?? 0 > characterPhrases[char2.id]?.count ?? 0
                            })
                            ForEach(characters) { character in
                                Button {
                                    select(with: character.id, from: characters)
                                } label: {
                                    let selected = selectedCharacters.contains(character.id)
                                    HStack {
                                        CustomLabel<BodyLargeStyle>(text: character.name)
                                            .foregroundColor(character.color)
                                            .lineLimit(1)
                                        Spacer()
                                        CustomLabel<BodyMediumStyle>(text: "\(L10n.phrasesCount.capitalized): \(characterPhrases[character.id]?.count ?? 0)")
                                            .foregroundColor(selected ? Asset.semiWhite.swiftUIColor : Asset.contentTertiary.swiftUIColor)
                                    }
                                    .padding(.vertical, 5)
                                    .padding(.horizontal, 10)
                                    .background(selected ? Asset.accentPrimary.swiftUIColor : Asset.surfacePrimary.swiftUIColor)
                                    .cornerRadius(5)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .focusable(false)
                            }
                        }
                        .padding(.all, 10)
                    }
                    .background(Asset.surfaceTertiary.swiftUIColor)
                    .cornerRadius(10)
                }
            }
        }
    }

    private var detailed: some View {
        VStack {
            if let characters = document.project.scriptFile?.characters.filter({ char in selectedCharacters.contains(char.id) }) {
                if characters.count == 1 {
                    if let character = characters.first {
                        CustomLabel<Header3Style>(text: character.name)
                            .foregroundColor(character.color)
                            .lineLimit(1)
                        ColorPicker(L10n.color.firstWordCapitalized, selection: Binding<Color>(
                            get: { character.color },
                            set: { newColor in
                                var character = character
                                character.color = newColor
                                document.project.scriptFile?.updateCharacter(by: character.id, with: character)
                            }
                        ))
                        .padding()
                        Spacer()
                        RoundedButton<RoundedButtonAlertMediumStyle>(title: L10n.delete.firstWordCapitalized, enabled: .constant(true)) {
                            document.project.scriptFile?.removeCharacter(by: character.id)
                            selectedCharacters = []
                        }
                    }
                } else if characters.count > 1 {
                    CustomLabel<Header3Style>(text: "\(L10n.charactersSelected.firstWordCapitalized): \(characters.count)")
                        .foregroundColor(Asset.contentPrimary.swiftUIColor)
                        .lineLimit(1)
                    Spacer()
                    RoundedButton<RoundedButtonAlertMediumStyle>(title: L10n.delete.firstWordCapitalized, enabled: .constant(true)) {
                        document.project.scriptFile?.removeCharacters(by: selectedCharacters)
                        selectedCharacters = []
                    }
                }
            }
        }
    }

    private func select(with id: UUID, from characters: [ScriptCharacter]) {
        guard let index = characters.firstIndex(where: { char in char.id == id }) else { return }
        if commandKeyPressed {
            selectedCharacters.append(id)
            lastSelectedCharacterIndex = index
            return
        }
        if shiftKeyPressed, let lastIndex = lastSelectedCharacterIndex {
            let start = min(index, lastIndex)
            let end = max(index, lastIndex)
            characters[start...end].forEach({ char in
                if !selectedCharacters.contains(char.id) {
                    selectedCharacters.append(char.id)
                }
            })
            lastSelectedCharacterIndex = index
            return
        }
        selectedCharacters = [id]
        lastSelectedCharacterIndex = index
    }
}
