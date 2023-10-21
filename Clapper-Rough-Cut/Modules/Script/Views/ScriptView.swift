import Foundation
import SwiftUI

struct ScriptView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var document: ClapperRoughCutDocument

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                if let file = document.project.scriptFile {
                    CustomLabel<Header3Style>(text: file.url.deletingPathExtension().lastPathComponent)
                        .foregroundColor(.contentPrimary(colorScheme))
                } else {
                    RoundedButton<RoundedButtonSecondaryMediumStyle>(title: L10n.addScript.capitalized,
                                                                   imageName: SystemImage.plus.rawValue,
                                                                   enabled: .constant(true)) {
                        document.addScriptFile()
                    }
                }
                Spacer()
            }
            .padding(.all, 10)
            if let file = document.project.scriptFile {
                let blocks = file.blocks
                ScrollView {
                    LazyVStack {
                        ForEach(blocks) { block in
                            let isDialogue = block.isDialogue
                            if isDialogue {
                                VStack {
                                    ForEach(block.phrases) { phrase in
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
                            } else {
                                CustomLabel<BodyMediumStyle>(text: block.fullText.trimmingCharacters(in: .whitespacesAndNewlines))
                                    .foregroundColor(.contentPrimary(colorScheme))
                            }
                        }
                    }
                    .padding(.top)
                    .padding(.horizontal)
                }
                .frame(maxHeight: .infinity)
            }
        }
        .frame(minWidth: 300, idealWidth: 400, maxWidth: 600,
               minHeight: 500, maxHeight: .infinity)
        .background(Color.surfaceSecondary(colorScheme))
        .sheet(isPresented: $document.states.isCharactersViewPresented) {
            if let scriptFile = document.project.scriptFile {
                let characterPhrasesMap: [UUID: [Phrase]] = scriptFile.characters.reduce(into: [:]) { result, character in
                    let phrases = scriptFile.getCharacterPhrases(character: character)
                    if !phrases.isEmpty {
                        result[character.id] = phrases
                    }
                }
                CharactersSettingsView(characterPhrases: characterPhrasesMap) {
                    document.states.isCharactersViewPresented.toggle()
                }
            }
        }
    }
}
