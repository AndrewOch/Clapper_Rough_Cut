//
//  SelectSceneMatchView.swift
//  Clapper-Rough-Cut
//
//  Created by andrewoch on 18.04.2023.
//

import SwiftUI

struct SelectPhraseMatchView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @State var selectAction: (Phrase) -> Void
    @State var closeAction: () -> Void
    @State var searchText: String = ""
    
    var body: some View {
        VStack {
            HStack {
                TextField("Выберите фразу...", text: $searchText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .focusable(false)
                    .foregroundColor(.black)
                    .cornerRadius(15)
                    .border(.gray)
                    
                Spacer()
                Button(action: closeAction) {
                    Image(systemName: "xmark")
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
        var blocks = document.project.scriptFile?.blocks.filter({ $0.isDialogue }) ?? []
        for block in blocks {
            phrases += block.phrases
        }
        if searchText.isNotEmpty {
            phrases = phrases.filter { phrase in phrase.fullText.lowercased().contains(searchText.lowercased())}
        }
        return phrases
    }
}
