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
                    SelectPhraseMatchView() { phrase in
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
                        Text("Распознанная речь")
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
                    PrimaryButton(title: "Расшифровать", imageName: "rectangle.and.pencil.and.ellipsis", accesibilityIdentifier: "", enabled: .constant(true)) {
                        document.transcribeFile(file)
                    }
                    Spacer()
                }
            }
            if let folder = document.getPhraseFolder(for: file) {
                VStack {
                    HStack {
                        Image(systemName: "folder")
                            .foregroundColor(.gray)
                        Text(folder.title)
                            .foregroundColor(.gray)
                        Spacer()
                        PrimaryButton(title: "Заменить сцену",
                                      imageName: "film",
                                      accesibilityIdentifier: "",
                                      enabled: .constant(true)) {
                            isModalPresented.toggle()
                        }
                    }
                }
            } else {
                VStack {
                    HStack {
                        PrimaryButton(title: "Определить сцену",
                                      imageName: "film",
                                      accesibilityIdentifier: "",
                                      enabled: .constant(file.transcription != nil)) {
                            document.matchSceneForFile(file)
                        }
                        PrimaryButton(title: "Выбрать сцену",
                                      imageName: "film",
                                      accesibilityIdentifier: "",
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
