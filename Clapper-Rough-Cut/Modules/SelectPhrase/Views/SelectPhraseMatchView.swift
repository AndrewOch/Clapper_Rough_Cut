import SwiftUI

struct SelectPhraseMatchView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var document: ClapperRoughCutDocument
    @State var selectAction: (ScriptBlockElement) -> Void
    @State var searchText: String = .empty

    var body: some View {
        CustomTextField(title: L10n.searchPhrase.firstWordCapitalized,
                           placeholder: L10n.searchPhrasePlaceholder.firstWordCapitalized,
                           text: $searchText)
        ScrollView {
            LazyVStack {
                ForEach(getPhrases()) { phrase in
                    Button {
                        selectAction(phrase)
                    } label: {
                        HStack {
                            if let character = phrase.character, let phraseText = phrase.phraseText {
                                PhraseLabel(characterName: character.name,
                                            text: phraseText)
                            }
                            Spacer()
                        }
                        .padding(.all, 5)
                        .background(Color.surfacePrimary(colorScheme))
                        .cornerRadius(5)
                        .overlay(RoundedRectangle(cornerRadius: 5)
                            .stroke(Asset.accentLight.swiftUIColor, lineWidth: 1))
                    }
                    .focusable(false)
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.all, 10)
        }
        .background(Color.surfaceTertiary(colorScheme))
        .cornerRadius(10)
    }

    func getPhrases() -> [ScriptBlockElement] {
        var phrases: [ScriptBlockElement] = []
        let blocks = document.project.scriptFile?.blocks.filter({ $0.elementsType == .phrase }) ?? []
        for block in blocks {
            phrases += block.elements
        }
        if searchText.isNotEmpty {
            phrases = phrases.filter { phrase in phrase.fullText.lowercased().contains(searchText.lowercased()) }
        }
        return phrases
    }
}
