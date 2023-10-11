import SwiftUI

struct SeveralSelectionDetailView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @Binding var selection: Set<FileSystemElement.ID>
    @State private var isModalPresented = false

    var body: some View {
        VStack {
            HStack {
                SystemImage.rectangleStackFill.imageView
                    .foregroundColor(Asset.dark.swiftUIColor)
                CustomLabel<BodyMediumStyle>(text: "\(L10n.selected.firstWordCapitalized): \(selection.count)")
                    .lineLimit(1)
                    .foregroundColor(Asset.dark.swiftUIColor)
                Spacer()
            }.padding(.bottom)
                .foregroundStyle(Asset.dark.swiftUIColor)
            HStack {
                VStack {
                    CustomLabel<BodyMediumStyle>(text: "\(L10n.folders.firstWordCapitalized): \(selection.filter( { id in document.project.firstFileSystemElement(where: { $0.id == id })?.type == .folder}).count)")
                        .lineLimit(1)
                        .foregroundColor(Asset.dark.swiftUIColor)
                    CustomLabel<BodyMediumStyle>(text: "\(L10n.scenes.firstWordCapitalized): \(selection.filter( { id in document.project.firstFileSystemElement(where: { $0.id == id })?.type == .scene}).count)")
                        .lineLimit(1)
                        .foregroundColor(Asset.dark.swiftUIColor)
                    CustomLabel<BodyMediumStyle>(text: "\(L10n.takes.firstWordCapitalized): \(selection.filter( { id in document.project.firstFileSystemElement(where: { $0.id == id })?.type == .take}).count)")
                        .lineLimit(1)
                        .foregroundColor(Asset.dark.swiftUIColor)
                    CustomLabel<BodyMediumStyle>(text: "\(L10n.audio.firstWordCapitalized): \(selection.filter( { id in document.project.firstFileSystemElement(where: { $0.id == id })?.type == .audio}).count)")
                        .lineLimit(1)
                        .foregroundColor(Asset.dark.swiftUIColor)
                    CustomLabel<BodyMediumStyle>(text: "\(L10n.video.firstWordCapitalized): \(selection.filter( { id in document.project.firstFileSystemElement(where: { $0.id == id })?.type == .video}).count)")
                        .lineLimit(1)
                        .foregroundColor(Asset.dark.swiftUIColor)
                }
                Spacer()
            }
        }
    }
}
