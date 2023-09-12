import SwiftUI

struct RawFolderDetailView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @Binding var folder: RawFilesFolder?
    @State private var isModalPresented = false

    var body: some View {
        if let folder = folder {
                HStack {
                    SystemImage.folder.imageView
                        .foregroundColor(Asset.semiDark.swiftUIColor)
                    Label<BodyMediumStyle>(text: folder.title)
                        .foregroundColor(Asset.semiDark.swiftUIColor)
                    Spacer()
                    if document.project.unsortedFolder != folder {
                        RoundedButton<RoundedButtonPrimaryMediumStyle>(title: L10n.changeScene.capitalized,
                                                                       imageName: SystemImage.film.rawValue,
                                      enabled: .constant(true)) {
                            isModalPresented.toggle()
                        }
                    }
                }
                .sheet(isPresented: $isModalPresented) {
                    ModalSheet(title: "Выберите сцену", resizableVertical: true) {
                        SelectPhraseMatchView { phrase in
                            document.changeScene(for: folder, phrase: phrase)
                            isModalPresented.toggle()
                        }
                    } closeAction: {
                        isModalPresented.toggle()
                    }
                }

                HStack {
                    FileIcon(type: .video)
                    Label<BodyMediumStyle>(text: "\(folder.files.filter({ file in file.type == .video }).count) \(L10n.video)")
                    Spacer()
                }
                .foregroundColor(Asset.dark.swiftUIColor)
                .padding(.vertical, 5)
                HStack {
                    FileIcon(type: .audio)
                    Label<BodyMediumStyle>(text: "\(folder.files.filter({ file in file.type == .audio }).count) \(L10n.audio)")
                    Spacer()
                }
                .foregroundColor(.black)
                .padding(.vertical, 5)
                HStack {
                    SystemImage.filmStack.imageView
                    Label<BodyMediumStyle>(text: "\(folder.takes.count) \(L10n.takes)")
                    Spacer()
                }
                .foregroundColor(Asset.dark.swiftUIColor)
                .padding(.vertical, 5)
        }
    }
}
