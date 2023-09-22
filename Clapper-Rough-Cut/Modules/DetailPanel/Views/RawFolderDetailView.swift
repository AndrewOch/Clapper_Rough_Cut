import SwiftUI

struct RawFolderDetailView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @Binding var folder: FileSystemElement?
    @State private var isModalPresented = false

    var body: some View {
        if let folder = folder {
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
            .sheet(isPresented: $isModalPresented) {
                ModalSheet(title: L10n.sceneSelection.firstWordCapitalized, resizableVertical: true) {
                    SelectPhraseMatchView { phrase in
                        document.changePhrase(for: folder, phrase: phrase)
                        isModalPresented.toggle()
                    }
                } closeAction: {
                    isModalPresented.toggle()
                }
            }
            
            HStack {
                FileIcon(type: .video)
                CustomLabel<BodyMediumStyle>(text: "\(folder.elements.values.filter({ file in file.type == .video }).count) \(L10n.video)")
                Spacer()
            }
            .foregroundColor(Asset.dark.swiftUIColor)
            .padding(.vertical, 5)
            HStack {
                FileIcon(type: .audio)
                CustomLabel<BodyMediumStyle>(text: "\(folder.elements.values.filter({ file in file.type == .audio }).count) \(L10n.audio)")
                Spacer()
            }
            .foregroundColor(.black)
            .padding(.vertical, 5)
            HStack {
                SystemImage.filmStack.imageView
                CustomLabel<BodyMediumStyle>(text: "\(folder.elements.count) \(L10n.takes)")
                Spacer()
            }
            .foregroundColor(Asset.dark.swiftUIColor)
            .padding(.vertical, 5)
        }
    }
}
