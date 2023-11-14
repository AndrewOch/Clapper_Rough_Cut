import SwiftUI

struct FileSystemSelectionDetailView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var document: ClapperRoughCutDocument
    @Binding var element: FileSystemElement
    @Binding var currentTime: Double
    @State private var isModalPresented = false
    @State private var subtitlesMode: Int = SubtitlesMode.full.rawValue

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
                .foregroundColor(.contentPrimary(colorScheme))
            CustomLabel<BodyMediumStyle>(text: element.title)
                .lineLimit(1)
                .foregroundColor(.contentPrimary(colorScheme))
            Spacer()
            if let duration = element.duration {
                CustomLabel<BodyMediumStyle>(text: Formatter.formatDuration(duration: duration))
                    .foregroundColor(.contentPrimary(colorScheme))
            }
            if let createdAt = element.createdAt {
                CustomLabel<BodyMediumStyle>(text: Formatter.formatDateShort(date: createdAt))
                    .foregroundColor(.contentSecondary(colorScheme))
                    .lineLimit(1)
            }
        }
        .padding(.bottom)
        .foregroundStyle(Color.contentPrimary(colorScheme))
    }

    var fileDetailInfo: some View {
        VStack {
            if !element.statuses.contains(where: { $0 == .transcription || $0 == .transcribing }) {
                HStack {
                    RoundedButton<RoundedButtonPrimaryMediumStyle>(title: L10n.transcribe.capitalized,
                                                                   imageName: SystemImage.rectangleAndPencilAndEllipsis.rawValue,
                                                                   enabled: .constant(true)) {
                        document.transcribeFile(element)
                    }
                    Spacer()
                }
            } else {
                VStack {
                    HStack {
                        TranscribedIcon()
                        CustomLabel<BodyMediumStyle>(text: L10n.transcribedSpeech.capitalized)
                        Spacer()
                        CustomPicker(selectedOption: $subtitlesMode, options: SubtitlesMode.images)
                            .frame(width: 100)
                    }
                    .foregroundColor(.contentSecondary(colorScheme))
                    ScrollView {
                        HStack {
                            if element.statuses.contains(.transcribing) {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .scaleEffect(0.5)
                                    .foregroundColor(.contentPrimary(colorScheme))
                            }
                            if subtitlesMode == 0, let subtitles = element.subtitles {
                                SubtitlesView(subtitles: .getOnly(subtitles))
                            }
                            if subtitlesMode == 1, let subtitle = element.currentSubtitle(time: currentTime) {
                                SubtitlesView(subtitles: .getOnly([subtitle]))
                            }
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.surfacePrimary(colorScheme))
                .cornerRadius(5)
                .overlay(RoundedRectangle(cornerRadius: 5)
                    .stroke(Asset.accentLight.swiftUIColor, lineWidth: 1))
                .padding(.bottom, 10)
            }
            if let folder = document.project.fileSystem.getContainer(forElementWithID: element.id) {
                VStack {
                    HStack {
                        FileIcon(type: .scene)
                            .foregroundColor(.contentSecondary(colorScheme))
                        CustomBindedLabel<BodyMediumStyle>(text: .getOnly(folder.title))
                            .foregroundColor(.contentSecondary(colorScheme))
                        Spacer()
                        RoundedButton<RoundedButtonSecondaryMediumStyle>(title: L10n.changeScene.capitalized,
                                                                       imageName: SystemImage.film.rawValue,
                                                                       enabled: .constant(true)) {
                            isModalPresented.toggle()
                        }
                    }
                }
            } else {
                HStack {
                    RoundedButton<RoundedButtonSecondaryMediumStyle>(title: L10n.determineScene.capitalized,
                                                                   imageName: SystemImage.film.rawValue,
                                                                   enabled: .constant(element.subtitles != nil)) {
                        document.matchSceneForFile(element)
                    }
                    RoundedButton<RoundedButtonSecondaryMediumStyle>(title: L10n.chooseScene.capitalized,
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
            let fileSystem = document.project.fileSystem
            let videoCount = fileSystem.allElements(where: { $0.containerId == element.id && $0.type == .video }).count
            let audioCount = fileSystem.allElements(where: { $0.containerId == element.id && $0.type == .audio }).count
            let takesCount = fileSystem.allElements(where: { $0.containerId == element.id && $0.isTake }).count
            HStack {
                FileIcon(type: .video)
                CustomLabel<BodyMediumStyle>(text: "\(videoCount) \(L10n.video)")
                Spacer()
            }
            .foregroundColor(.contentPrimary(colorScheme))
            .padding(.vertical, 5)
            HStack {
                FileIcon(type: .audio)
                CustomLabel<BodyMediumStyle>(text: "\(audioCount) \(L10n.audio)")
                Spacer()
            }
            .foregroundColor(.black)
            .padding(.vertical, 5)
            HStack {
                SystemImage.filmStack.imageView
                CustomLabel<BodyMediumStyle>(text: "\(takesCount) \(L10n.takes)")
                Spacer()
            }
            .foregroundColor(.contentPrimary(colorScheme))
            .padding(.vertical, 5)
            if (element.scriptPhraseId != nil) {
                VStack {
                    HStack {
                        SystemImage.film.imageView
                            .foregroundColor(.contentSecondary(colorScheme))
                        CustomLabel<BodyMediumStyle>(text: element.title)
                            .foregroundColor(.contentSecondary(colorScheme))
                        Spacer()
                        RoundedButton<RoundedButtonSecondaryMediumStyle>(title: L10n.changeScene.firstWordCapitalized,
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
            ForEach(document.project.fileSystem.allElements(where: { $0.containerId == element.id })) { element in
                HStack {
                    if let url = element.url, let duration = element.duration, let createdAt = element.createdAt {
                        FileIcon(type: element.type)
                            .foregroundColor(.contentPrimary(colorScheme))
                        CustomLabel<BodyMediumStyle>(text: url.lastPathComponent)
                            .lineLimit(1)
                            .foregroundColor(.contentPrimary(colorScheme))
                        Spacer()
                        CustomLabel<BodyMediumStyle>(text: Formatter.formatDuration(duration: duration))
                            .foregroundColor(.contentPrimary(colorScheme))
                        CustomLabel<BodyMediumStyle>(text: Formatter.formatDate(date: createdAt))
                            .foregroundColor(.contentSecondary(colorScheme))
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
