import SwiftUI

struct RawTakeDetailView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @Binding var take: RawTake?
    @State private var isModalPresented = false

    var body: some View {
        if let take = take {
            HStack {
                FileIcon(type: take.video.type)
                    .foregroundColor(Asset.dark.swiftUIColor)
                Label<BodyMediumStyle>(text: take.video.url.lastPathComponent)
                    .lineLimit(1)
                    .foregroundColor(Asset.dark.swiftUIColor)
                Spacer()
                Label<BodyMediumStyle>(text: Formatter.formatDuration(duration: take.video.duration))
                    .foregroundColor(Asset.dark.swiftUIColor)
                Label<BodyMediumStyle>(text: Formatter.formatDate(date: take.video.createdAt))
                    .foregroundColor(Asset.semiDark.swiftUIColor)
            }.padding(.bottom)
                .sheet(isPresented: $isModalPresented) {
                    ModalSheet(title: "Выберите сцену", resizableVertical: true) {
                        SelectPhraseMatchView { phrase in
                            document.manualMatch(take: take, phrase: phrase)
                            isModalPresented.toggle()
                        }
                    } closeAction: {
                        isModalPresented.toggle()
                    }
                }
            HStack {
                FileIcon(type: take.audio.type)
                    .foregroundColor(Asset.dark.swiftUIColor)
                Label<BodyMediumStyle>(text: take.audio.url.lastPathComponent)
                    .lineLimit(1)
                    .foregroundColor(Asset.dark.swiftUIColor)
                Spacer()
                Label<BodyMediumStyle>(text: Formatter.formatDuration(duration: take.audio.duration))
                    .foregroundColor(Asset.dark.swiftUIColor)
                Label<BodyMediumStyle>(text: Formatter.formatDate(date: take.audio.createdAt))
                    .foregroundColor(Asset.semiDark.swiftUIColor)
            }.padding(.bottom)

            if let folder = document.getPhraseFolder(for: take) {
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
