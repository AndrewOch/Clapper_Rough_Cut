import SwiftUI

struct FileSystemSelectionDetailView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @State private var isModalPresented = false
    @Binding var element: FileSystemElement

    var body: some View {
        VStack {
            baseDetailInfo
            if element.isFile {
                fileDetailInfo
            }
            if element.isScene {
                sceneDetailInfo
            }
            if element.isTake {
                takeDetailInfo
            }
        }
    }

    var baseDetailInfo: some View {
        HStack {
            FileIcon(type: element.type)
                .foregroundColor(Asset.dark.swiftUIColor)
            CustomLabel<BodyMediumStyle>(text: element.title)
                .lineLimit(1)
                .foregroundColor(Asset.dark.swiftUIColor)
            Spacer()
            if let duration = element.duration {
                CustomLabel<BodyMediumStyle>(text: Formatter.formatDuration(duration: duration))
                    .foregroundColor(Asset.dark.swiftUIColor)
            }
            if let createdAt = element.createdAt {
                CustomLabel<BodyMediumStyle>(text: Formatter.formatDate(date: createdAt))
                    .foregroundColor(Asset.semiDark.swiftUIColor)
            }
        }.padding(.bottom)
            .foregroundStyle(Asset.dark.swiftUIColor)
    }

    var fileDetailInfo: some View {
        VStack {
            if let transcription = element.transcription {
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
                        document.transcribeFile(element)
                    }
                    Spacer()
                }
            }
            if let folder = document.project.getContainer(forElementWithID: element.id) {
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
                                                                   enabled: .constant(element.transcription != nil)) {
                        document.matchSceneForFile(element)
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
        .sheet(isPresented: $isModalPresented) {
            ModalSheet(title: L10n.sceneSelection.firstWordCapitalized, resizableVertical: true) {
                SelectPhraseMatchView { phrase in
                    document.manualMatch(element: element, phrase: phrase)
                    isModalPresented.toggle()
                }
            } closeAction: {
                isModalPresented.toggle()
            }
        }
    }

    var sceneDetailInfo: some View {
        VStack {
            HStack {
                FileIcon(type: .video)
                CustomLabel<BodyMediumStyle>(text: "\(element.elements?.filter({ file in file.type == .video }).count ?? 0) \(L10n.video)")
                Spacer()
            }
            .foregroundColor(Asset.dark.swiftUIColor)
            .padding(.vertical, 5)
            HStack {
                FileIcon(type: .audio)
                CustomLabel<BodyMediumStyle>(text: "\(element.elements?.filter({ file in file.type == .audio }).count ?? 0) \(L10n.audio)")
                Spacer()
            }
            .foregroundColor(.black)
            .padding(.vertical, 5)
            HStack {
                SystemImage.filmStack.imageView
                CustomLabel<BodyMediumStyle>(text: "\(element.elements?.filter({ $0.isTake }).count ?? 0) \(L10n.takes)")
                Spacer()
            }
            .foregroundColor(Asset.dark.swiftUIColor)
            .padding(.vertical, 5)
            if let phrase = element.scriptPhraseId {
                VStack {
                    HStack {
                        SystemImage.film.imageView
                            .foregroundColor(Asset.semiDark.swiftUIColor)
                        CustomLabel<BodyMediumStyle>(text: element.title)
                            .foregroundColor(Asset.semiDark.swiftUIColor)
                        Spacer()
                        RoundedButton<RoundedButtonPrimaryMediumStyle>(title: L10n.changeScene.firstWordCapitalized,
                                                                       imageName: SystemImage.film.rawValue,
                                                                       enabled: .constant(true)) {
                            isModalPresented.toggle()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isModalPresented) {
            ModalSheet(title: L10n.sceneSelection.firstWordCapitalized, resizableVertical: true) {
                SelectPhraseMatchView { phrase in
                    document.changePhrase(for: element, phrase: phrase)
                    isModalPresented.toggle()
                }
            } closeAction: {
                isModalPresented.toggle()
            }
        }
    }

    var takeDetailInfo: some View {
        VStack {
            ForEach(element.elements ?? []) { element in
                HStack {
                    if let url = element.url, let duration = element.duration, let createdAt = element.createdAt {
                        FileIcon(type: element.type)
                            .foregroundColor(Asset.dark.swiftUIColor)
                        CustomLabel<BodyMediumStyle>(text: url.lastPathComponent)
                            .lineLimit(1)
                            .foregroundColor(Asset.dark.swiftUIColor)
                        Spacer()
                        CustomLabel<BodyMediumStyle>(text: Formatter.formatDuration(duration: duration))
                            .foregroundColor(Asset.dark.swiftUIColor)
                        CustomLabel<BodyMediumStyle>(text: Formatter.formatDate(date: createdAt))
                            .foregroundColor(Asset.semiDark.swiftUIColor)
                    }
                }.padding(.bottom)
                    .sheet(isPresented: $isModalPresented) {
                        ModalSheet(title: L10n.sceneSelection.firstWordCapitalized, resizableVertical: true) {
                            SelectPhraseMatchView { phrase in
                                document.manualMatch(element: element, phrase: phrase)
                                isModalPresented.toggle()
                            }
                        } closeAction: {
                            isModalPresented.toggle()
                        }
                    }
            }
        }
    }
}
