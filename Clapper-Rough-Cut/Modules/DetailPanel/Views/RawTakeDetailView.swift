import SwiftUI

struct RawTakeDetailView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @Binding var take: FileSystemElement?
    @State private var isModalPresented = false

    var body: some View {
        if let take = take {
            ForEach(Array(take.elements.values)) { element in
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
                                document.manualMatch(element: take, phrase: phrase)
                                isModalPresented.toggle()
                            }
                        } closeAction: {
                            isModalPresented.toggle()
                        }
                    }
            }
            if let folder = document.project.getContainer(forElementWithID: take.id) {
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
                    HStack {
                        RoundedButton<RoundedButtonPrimaryMediumStyle>(title: L10n.unwrapFiles.capitalized,
                                      imageName: nil,
                                      enabled: .constant(true)) {
                            document.detachFiles(from: take)
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}
