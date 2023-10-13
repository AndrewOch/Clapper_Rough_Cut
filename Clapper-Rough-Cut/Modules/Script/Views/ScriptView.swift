import Foundation
import SwiftUI

struct ScriptView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                if let file = document.project.scriptFile {
                    CustomLabel<Header3Style>(text: file.url.deletingPathExtension().lastPathComponent)
                        .foregroundColor(Asset.dark.swiftUIColor)
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
                                        .foregroundColor(Asset.dark.swiftUIColor)
                                    }
                                }
                                .padding(.all, 5)
                                .background(Asset.white.swiftUIColor)
                                    .cornerRadius(5)
                                    .overlay(RoundedRectangle(cornerRadius: 5)
                                        .stroke(Asset.accentLight.swiftUIColor, lineWidth: 1))
                            } else {
                                CustomLabel<BodyMediumStyle>(text: block.fullText.trimmingCharacters(in: .whitespacesAndNewlines))
                                    .foregroundColor(Asset.dark.swiftUIColor)
                            }
                        }
                    }
                    .padding(.top)
                    .padding(.horizontal)
                }
                .frame(maxHeight: .infinity)
            }
        }
        .frame(minWidth: 300, maxWidth: .infinity,
               minHeight: 500, maxHeight: .infinity)
        .background(Asset.semiWhite.swiftUIColor)
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
