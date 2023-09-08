import SwiftUI

struct SelectPhraseMatchView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @State var selectAction: (Phrase) -> Void
    @State var closeAction: () -> Void
    @State var searchText: String = .empty

    var body: some View {
        VStack {
            HStack {
                TextFieldComponent(placeholder: L10n.askToSelectScene.capitalized, text: $searchText)

                Spacer()
                Button(action: closeAction) {
                    SystemImage.xmark.imageView
                        .foregroundColor(.black)
                }.buttonStyle(PlainButtonStyle())
                    .focusable(false)
            }
            .padding(.bottom)
            ScrollView {
                LazyVStack {
                        ForEach(getPhrases()) { phrase in
                            Button {
                                selectAction(phrase)
                            } label: {
                                HStack {
                                    Text(phrase.characterName)
                                        .bold()
                                        .foregroundColor(.black)
                                    + Text(": \(phrase.phraseText)")
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                                .padding(.all, 5)
                                .background(.white)
                                .cornerRadius(5)
                            }
                            .focusable(false)
                            .buttonStyle(PlainButtonStyle())
                        }
                }
                .padding(.all, 10)
            }
            .background(.gray.opacity(0.3))
            .cornerRadius(15)
        }
        .padding()
        .frame(minWidth: 500, idealWidth: 500, maxWidth: .infinity)
        .frame(minHeight: 600, idealHeight: 600, maxHeight: .infinity)
        .background(.white)
        .cornerRadius(15)
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
