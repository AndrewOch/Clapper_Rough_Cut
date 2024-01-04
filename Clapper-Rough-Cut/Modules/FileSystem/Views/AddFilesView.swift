import SwiftUI

struct AddFilesView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @State var elements: [FileSystemElement] = []
    @State var deviceName: String = .empty
    @State var selectedDevice: UUID?
    @State var addAction: ([FileSystemElement], ElementDevice) -> Void
    @State var closeAction: () -> Void

    var body: some View {
        ModalSheet(title: L10n.addFiles.capitalized) {
            VStack {
                HStack {
                    CustomLabel<BodyMediumStyle>(text: L10n.files.capitalized)
                    Spacer()
                    ImageButton<ImageButtonSystemStyle>(image: SystemImage.squareAndArrowDown.imageView, enabled: .constant(true)) {
                        elements.append(contentsOf: document.downloadRawFiles(existingElems: elements))
                    }
                }
                ScrollView {
                    LazyVStack {
                        ForEach(elements) { element in
                            HStack {
                                HStack {
                                    FileIcon(type: element.type)
                                    CustomLabel<BodySmallStyle>(text: element.title)
                                }
                                Spacer()
                                ImageButton<ImageButtonSystemStyle>(image: SystemImage.xmark.imageView, 
                                                                    enabled: .constant(true)) {
                                    elements.removeAll(where: { $0.id == element.id })
                                }
                            }
                        }
                    }
                }
                .background(Asset.surfaceSecondary.swiftUIColor)
            }
            HStack(alignment: .bottom) {
                CustomTextField(title: L10n.exportPath.capitalized,
                                placeholder: L10n.exportPathPlaceholder.firstWordCapitalized,
                                text: $deviceName)
                RoundedButton<RoundedButtonSecondaryMediumStyle>(title: L10n.choose.capitalized,
                                                                 enabled: .constant(true)) {
                    document.selectExportFolder()
                }
            }
            .padding(.bottom)
        } actionBarContent: {
            RoundedButton<RoundedButtonPrimaryMediumStyle>(title: L10n.addFiles.capitalized,
                                                           enabled: .constant(true)) {
                addAction(elements, ElementDevice(name: deviceName))
            }
        } closeAction: {
            closeAction()
        }
    }
}
