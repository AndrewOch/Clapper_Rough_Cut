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
                        .foregroundColor(Asset.contentPrimary.swiftUIColor)
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
                            ScriptBlockView(block: .getOnly(block))
                        }
                    }
                    .padding(.top)
                    .padding(.horizontal)
                }
                .frame(maxHeight: .infinity)
            }
        }
        .frame(minWidth: 300, idealWidth: 400, maxWidth: 580,
               minHeight: 500, maxHeight: .infinity)
        .background(Asset.surfaceSecondary.swiftUIColor)
        .sheet(isPresented: $document.states.isCharactersViewPresented) {
            if let scriptFile = document.project.scriptFile {
                let characterPhrasesMap: [UUID: [ScriptBlockElement]] = scriptFile.characters.reduce(into: [:]) { result, character in
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
