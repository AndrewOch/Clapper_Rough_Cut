import SwiftUI

struct SelectPhraseMatchView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @State var selectAction: (Phrase) -> Void
    @State var searchText: String = .empty

    var body: some View {
        TextFieldComponent(placeholder: L10n.askToSelectScene.capitalized, text: $searchText)
        ScrollView {
            LazyVStack {
                ForEach(getPhrases()) { phrase in
                    Button {
                        selectAction(phrase)
                    } label: {
                        HStack {
                            PhraseLabel(characterName: phrase.characterName,
                                        text: phrase.phraseText)
                            Spacer()
                        }
                        .padding(.all, 5)
                        .background(Asset.white.swiftUIColor)
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
        .background(Asset.secondary.swiftUIColor)
        .cornerRadius(10)
    }

    func getPhrases() -> [Phrase] {
        var phrases: [Phrase] = []
        let blocks = document.project.scriptFile?.blocks.filter({ $0.isDialogue }) ?? []
        for block in blocks {
            phrases += block.phrases
        }
        if searchText.isNotEmpty {
            phrases = phrases.filter { phrase in phrase.fullText.lowercased().contains(searchText.lowercased()) }
        }
        return phrases
    }
}
