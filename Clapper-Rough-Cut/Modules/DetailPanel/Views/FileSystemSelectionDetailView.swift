import SwiftUI

struct FileSystemSelectionDetailView: View {

    @EnvironmentObject var document: ClapperRoughCutDocument
    @Binding var element: FileSystemElement
    @Binding var currentTime: Double
    @State private var isModalPresented = false
    @State private var subtitlesMode: Int = SubtitlesMode.full.rawValue
    @Binding var selection: Set<FileSystemElement.ID>

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
                .foregroundColor(Asset.contentPrimary.swiftUIColor)
            CustomLabel<BodyMediumStyle>(text: element.title)
                .lineLimit(1)
                .foregroundColor(Asset.contentPrimary.swiftUIColor)
            Spacer()
            if let duration = element.duration {
                CustomLabel<BodyMediumStyle>(text: Formatter.formatDuration(duration: duration))
                    .foregroundColor(Asset.contentPrimary.swiftUIColor)
            }
            if let createdAt = element.createdAt {
                CustomLabel<BodyMediumStyle>(text: Formatter.formatDateShort(date: createdAt))
                    .foregroundColor(Asset.contentSecondary.swiftUIColor)
                    .lineLimit(1)
            }
        }
        .padding(.bottom)
        .foregroundStyle(Asset.contentPrimary.swiftUIColor)
    }

    var fileDetailInfo: some View {
        VStack {
            if element.statuses.isEmpty {
                HStack {
                    RoundedButton<RoundedButtonPrimaryMediumStyle>(title: L10n.transcribe.capitalized,
                                                                   imageName: SystemImage.rectangleAndPencilAndEllipsis.rawValue,
                                                                   enabled: .constant(true)) {
                        document.transcribeFile(element)
                    }
                    Spacer()
                }
            } else {
                VStack(spacing: 5) {
                    VStack {
                        HStack {
                            TranscribedIcon()
                            CustomLabel<BodyMediumStyle>(text: L10n.transcribedSpeech.capitalized)
                            Spacer()
                            CustomPicker(selectedOption: $subtitlesMode, options: SubtitlesMode.images)
                                .frame(width: 100)
                        }
                        .foregroundColor(Asset.contentSecondary.swiftUIColor)
                        ScrollView {
                            HStack {
                                if element.statuses.contains(.transcribing) {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .scaleEffect(0.5)
                                        .foregroundColor(Asset.contentPrimary.swiftUIColor)
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
                    .background(Asset.surfacePrimary.swiftUIColor)
                    .cornerRadius(5)
//                    .overlay(RoundedRectangle(cornerRadius: 5)
//                        .stroke(Asset.accentLight.swiftUIColor, lineWidth: 1))
                    .padding(.bottom, 5)
                    HStack {
                        VStack {
                            HStack {
                                AudioClassificationIcon()
                                CustomLabel<BodyMediumStyle>(text: L10n.classifiedAudio.capitalized)
                                Spacer()
                            }
                            .foregroundColor(Asset.contentSecondary.swiftUIColor)
                            ScrollView {
                                HStack {
                                    if element.statuses.contains(.audioClassifying) {
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                            .scaleEffect(0.5)
                                            .foregroundColor(Asset.contentPrimary.swiftUIColor)
                                    }
                                    ClassificationResultView(elements: element.audioClasses ?? [])
                                }
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 5)
                        .padding(.vertical, 5)
                        .background(Asset.surfacePrimary.swiftUIColor)
                        .cornerRadius(5)
//                        .overlay(RoundedRectangle(cornerRadius: 5)
//                            .stroke(Asset.accentLight.swiftUIColor, lineWidth: 1))
                        .padding(.bottom, 10)
                        VStack {
                            HStack {
                                VideoClassificationIcon()
                                CustomLabel<BodyMediumStyle>(text: L10n.classifiedVideo)
                                Spacer()
                            }
                            .foregroundColor(Asset.contentSecondary.swiftUIColor)
                            ScrollView {
                                HStack {
                                    if element.statuses.contains(.videoCaptioning) {
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                            .scaleEffect(0.5)
                                            .foregroundColor(Asset.contentPrimary.swiftUIColor)
                                    }
                                    ClassificationResultView(elements: element.videoClasses ?? [])
                                }
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 5)
                        .padding(.vertical, 5)
                        .background(Asset.surfacePrimary.swiftUIColor)
                        .cornerRadius(5)
//                        .overlay(RoundedRectangle(cornerRadius: 5)
//                            .stroke(Asset.accentLight.swiftUIColor, lineWidth: 1))
                        .padding(.bottom, 10)
                    }
                }
            }
            if let folder = document.project.fileSystem.getContainer(forElementWithID: element.id),
               document.project.fileSystem.root != folder {
                VStack {
                    HStack {
                        FileIcon(type: .scene)
                            .foregroundColor(Asset.contentSecondary.swiftUIColor)
                        CustomBindedLabel<BodyMediumStyle>(text: .getOnly(folder.title))
                            .foregroundColor(Asset.contentSecondary.swiftUIColor)
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
                    selection.removeAll()
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
            .foregroundColor(Asset.contentPrimary.swiftUIColor)
            .padding(.vertical, 5)
            HStack {
                FileIcon(type: .audio)
                CustomLabel<BodyMediumStyle>(text: "\(audioCount) \(L10n.audio)")
                Spacer()
            }
            .foregroundColor(Asset.contentPrimary.swiftUIColor)
            .padding(.vertical, 5)
            HStack {
                SystemImage.filmStack.imageView
                CustomLabel<BodyMediumStyle>(text: "\(takesCount) \(L10n.takes)")
                Spacer()
            }
            .foregroundColor(Asset.contentPrimary.swiftUIColor)
            .padding(.vertical, 5)
            if (element.sceneId != nil) {
                VStack {
                    HStack {
                        SystemImage.film.imageView
                            .foregroundColor(Asset.contentSecondary.swiftUIColor)
                        CustomLabel<BodyMediumStyle>(text: element.title)
                            .foregroundColor(Asset.contentSecondary.swiftUIColor)
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
                            .foregroundColor(Asset.contentPrimary.swiftUIColor)
                        CustomLabel<BodyMediumStyle>(text: url.lastPathComponent)
                            .lineLimit(1)
                            .foregroundColor(Asset.contentPrimary.swiftUIColor)
                        Spacer()
                        CustomLabel<BodyMediumStyle>(text: Formatter.formatDuration(duration: duration))
                            .foregroundColor(Asset.contentPrimary.swiftUIColor)
                        CustomLabel<BodyMediumStyle>(text: Formatter.formatDate(date: createdAt))
                            .foregroundColor(Asset.contentSecondary.swiftUIColor)
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
