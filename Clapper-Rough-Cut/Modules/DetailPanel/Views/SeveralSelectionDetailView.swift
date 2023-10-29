import SwiftUI

struct SeveralSelectionDetailView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var document: ClapperRoughCutDocument
    @Binding var selection: Set<FileSystemElement.ID>
    @State private var isModalPresented = false

    var body: some View {
        VStack {
            HStack {
                SystemImage.rectangleStackFill.imageView
                    .foregroundColor(.contentPrimary(colorScheme))
                CustomLabel<BodyMediumStyle>(text: "\(L10n.selected.firstWordCapitalized): \(selection.count)")
                    .lineLimit(1)
                    .foregroundColor(.contentPrimary(colorScheme))
                Spacer()
            }.padding(.bottom)
                .foregroundStyle(Color.contentPrimary(colorScheme))
            HStack {
                VStack {
                    CustomLabel<BodyMediumStyle>(text: "\(L10n.folders.firstWordCapitalized): \(selection.filter({ id in document.project.fileSystem.elementById(id)?.type == .folder }).count)")
                        .lineLimit(1)
                        .foregroundColor(.contentPrimary(colorScheme))
                    CustomLabel<BodyMediumStyle>(text: "\(L10n.scenes.firstWordCapitalized): \(selection.filter({ id in document.project.fileSystem.elementById(id)?.type == .scene }).count)")
                        .lineLimit(1)
                        .foregroundColor(.contentPrimary(colorScheme))
                    CustomLabel<BodyMediumStyle>(text: "\(L10n.takes.firstWordCapitalized): \(selection.filter({ id in document.project.fileSystem.elementById(id)?.type == .take }).count)")
                        .lineLimit(1)
                        .foregroundColor(.contentPrimary(colorScheme))
                    CustomLabel<BodyMediumStyle>(text: "\(L10n.audio.firstWordCapitalized): \(selection.filter({ id in document.project.fileSystem.elementById(id)?.type == .audio }).count)")
                        .lineLimit(1)
                        .foregroundColor(.contentPrimary(colorScheme))
                    CustomLabel<BodyMediumStyle>(text: "\(L10n.video.firstWordCapitalized): \(selection.filter({ id in document.project.fileSystem.elementById(id)?.type == .video }).count)")
                        .lineLimit(1)
                        .foregroundColor(.contentPrimary(colorScheme))
                }
                Spacer()
            }
        }
    }
}
