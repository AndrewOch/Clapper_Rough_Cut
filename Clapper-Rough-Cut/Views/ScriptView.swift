import Foundation
import SwiftUI

struct ScriptView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    
    var body: some View {
        VStack {
            HStack {
                if let file = document.project.scriptFile {
                    Image(systemName: "doc")
                        .foregroundColor(.black)
                    Text(file.url.lastPathComponent)
                        .foregroundColor(.black)
                } else {
                    PrimaryButton(title: "Добавить сценарий", imageName: "plus", accesibilityIdentifier: "", enabled: .constant(true)) {
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
                                            Text(phrase.characterName)
                                                .bold() +
                                            Text(": \(phrase.phraseText)".trimmingCharacters(in: .whitespacesAndNewlines))
                                            Spacer()
                                        }
                                        .foregroundColor(.black)
                                    }
                                }
                                .padding(.all, 5)
                                    .background(.gray.opacity(0.3))
                                    .cornerRadius(5)
                            } else {
                                Text(block.fullText.trimmingCharacters(in: .whitespacesAndNewlines))
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .padding(.top)
                    .padding(.horizontal)
                }
                .frame(maxHeight: .infinity)
            }
            Spacer()
        }
        .frame(minWidth: 300, maxWidth: .infinity,
               minHeight: 500, maxHeight: .infinity)
        .background(Color.white)
    }
}


