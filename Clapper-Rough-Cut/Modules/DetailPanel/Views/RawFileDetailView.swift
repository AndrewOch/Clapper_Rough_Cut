import SwiftUI

struct RawFileDetailView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @Binding var file: FileSystemElement?
    @State private var isModalPresented = false

    var body: some View {
        VStack {
            if let file = file, let url = file.url, let duration = file.duration, let createdAt = file.createdAt {
                HStack {
                    FileIcon(type: file.type)
                        .foregroundColor(Asset.dark.swiftUIColor)
                    CustomLabel<BodyMediumStyle>(text: url.lastPathComponent)
                        .lineLimit(1)
                        .foregroundColor(Asset.dark.swiftUIColor)
                    Spacer()
                    CustomLabel<BodyMediumStyle>(text: Formatter.formatDuration(duration: duration))
                        .foregroundColor(Asset.dark.swiftUIColor)
                    CustomLabel<BodyMediumStyle>(text: Formatter.formatDate(date: createdAt))
                        .foregroundColor(Asset.semiDark.swiftUIColor)
                }.padding(.bottom)
                    .sheet(isPresented: $isModalPresented) {
                        ModalSheet(title: L10n.sceneSelection.firstWordCapitalized, resizableVertical: true) {
                            SelectPhraseMatchView { phrase in
                                document.manualMatch(element: file, phrase: phrase)
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
                            CustomLabel<BodyMediumStyle>(text: L10n.transcribedSpeech.capitalized)
                                .foregroundColor(Asset.semiDark.swiftUIColor)
                            Spacer()
                        }
                        ScrollView {
                            HStack {
                                CustomLabel<BodyMediumStyle>(text: transcription)
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
                if let folder = document.project.getContainer(forElementWithID: file.id) {
                    VStack {
                        HStack {
                            SystemImage.folder.imageView
                                .foregroundColor(Asset.semiDark.swiftUIColor)
                            CustomLabel<BodyMediumStyle>(text: folder.title)
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
