import SwiftUI

struct RawFileDetailView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @Binding var file: RawFile?
    @State private var isModalPresented = false

    var body: some View {
        if let file = file {
            HStack {
                FileIcon(type: file.type)
                    .foregroundColor(.black)
                Text(file.url.lastPathComponent)
                    .lineLimit(1)
                    .foregroundColor(.black)
                Spacer()
                Text(Formatter.formatDuration(duration: file.duration))
                    .foregroundColor(.black)
                Text(Formatter.formatDate(date: file.createdAt))
                    .foregroundColor(.gray)
            }.padding(.bottom)
                .sheet(isPresented: $isModalPresented) {
                    SelectPhraseMatchView { phrase in
                        document.manualMatch(file: file, phrase: phrase)
                        isModalPresented.toggle()
                    } closeAction: {
                        isModalPresented.toggle()
                    }
                }
            if let transcription = file.transcription {
                VStack {
                    HStack {
                        TranscribedIcon()
                            .foregroundColor(.gray)
                        Text(L10n.transcribedSpeech.capitalized)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    ScrollView {
                        HStack {
                            Text(transcription)
                                .foregroundColor(.black)
                            Spacer()
                        }
                    }
                }
            } else {
                HStack {
                    RoundedButton<RoundedButtonPrimaryMediumStyle>(title: L10n.transcribe.capitalized,
                                                                   imageName: SystemImage.rectangleAndPencilAndEllipsis.rawValue,
                                                                   enabled: .constant(true)) {
                        document.transcribeFile(file)
                    }
                    Spacer()
                }
            }
            if let folder = document.getPhraseFolder(for: file) {
                VStack {
                    HStack {
                        SystemImage.folder.imageView
                            .foregroundColor(.gray)
                        Text(folder.title)
                            .foregroundColor(.gray)
                        Spacer()
                        RoundedButton<RoundedButtonPrimaryMediumStyle>(title: L10n.changeScene.capitalized,
                                                                       imageName: SystemImage.film.rawValue,
                                      enabled: .constant(true)) {
                            isModalPresented.toggle()
                        }
                    }
                }
            } else {
                VStack {
                    HStack {
                        RoundedButton<RoundedButtonPrimaryMediumStyle>(title: L10n.determineScene.capitalized,
                                      imageName: SystemImage.film.rawValue,
                                      enabled: .constant(file.transcription != nil)) {
                            document.matchSceneForFile(file)
                        }
                        RoundedButton<RoundedButtonPrimaryMediumStyle>(title: L10n.chooseScene.capitalized,
                                      imageName: SystemImage.film.rawValue,
                                      enabled: .constant(true)) {
                            isModalPresented.toggle()
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}
