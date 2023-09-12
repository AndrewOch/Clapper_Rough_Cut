import SwiftUI

struct RawFileDetailView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @Binding var file: RawFile?
    @State private var isModalPresented = false

    var body: some View {
        VStack {
            if let file = file {
                HStack {
                    FileIcon(type: file.type)
                        .foregroundColor(Asset.dark.swiftUIColor)
                    Label<BodyMediumStyle>(text: file.url.lastPathComponent)
                        .lineLimit(1)
                        .foregroundColor(Asset.dark.swiftUIColor)
                    Spacer()
                    Label<BodyMediumStyle>(text: Formatter.formatDuration(duration: file.duration))
                        .foregroundColor(Asset.dark.swiftUIColor)
                    Label<BodyMediumStyle>(text: Formatter.formatDate(date: file.createdAt))
                        .foregroundColor(Asset.semiDark.swiftUIColor)
                }.padding(.bottom)
                    .sheet(isPresented: $isModalPresented) {
                        ModalSheet(title: "Выберите сцену", resizableVertical: true) {
                            SelectPhraseMatchView { phrase in
                                document.manualMatch(file: file, phrase: phrase)
                                isModalPresented.toggle()
                            }
                        } closeAction: {
                            isModalPresented.toggle()
                        }
                    }
                if let transcription = file.transcription {
                    VStack {
                        HStack {
                            TranscribedIcon()
                                .foregroundColor(Asset.semiDark.swiftUIColor)
                            Label<BodyMediumStyle>(text: L10n.transcribedSpeech.capitalized)
                                .foregroundColor(Asset.semiDark.swiftUIColor)
                            Spacer()
                        }
                        ScrollView {
                            HStack {
                                Label<BodyMediumStyle>(text: transcription)
                                    .foregroundColor(Asset.dark.swiftUIColor)
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
                                .foregroundColor(Asset.semiDark.swiftUIColor)
                            Label<BodyMediumStyle>(text: folder.title)
                                .foregroundColor(Asset.semiDark.swiftUIColor)
                            Spacer()
                            RoundedButton<RoundedButtonPrimaryMediumStyle>(title: L10n.changeScene.capitalized,
                                                                           imageName: SystemImage.film.rawValue,
                                                                           enabled: .constant(true)) {
                                isModalPresented.toggle()
                            }
                        }
                    }
                } else {
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
