import SwiftUI

struct RawTakeDetailView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @Binding var take: RawTake?
    @State private var isModalPresented = false

    var body: some View {
        if let take = take {
            HStack {
                FileIcon(type: take.video.type)
                    .foregroundColor(.black)
                Text(take.video.url.lastPathComponent)
                    .lineLimit(1)
                    .foregroundColor(.black)
                Spacer()
                Text(Formatter.formatDuration(duration: take.video.duration))
                    .foregroundColor(.black)
                Text(Formatter.formatDate(date: take.video.createdAt))
                    .foregroundColor(.gray)
            }.padding(.bottom)
                .sheet(isPresented: $isModalPresented) {
                    SelectPhraseMatchView { phrase in
                        document.manualMatch(take: take, phrase: phrase)
                        isModalPresented.toggle()
                    } closeAction: {
                        isModalPresented.toggle()
                    }
                }
            HStack {
                FileIcon(type: take.audio.type)
                    .foregroundColor(.black)
                Text(take.audio.url.lastPathComponent)
                    .lineLimit(1)
                    .foregroundColor(.black)
                Spacer()
                Text(Formatter.formatDuration(duration: take.audio.duration))
                    .foregroundColor(.black)
                Text(Formatter.formatDate(date: take.audio.createdAt))
                    .foregroundColor(.gray)
            }.padding(.bottom)

            if let folder = document.getPhraseFolder(for: take) {
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
