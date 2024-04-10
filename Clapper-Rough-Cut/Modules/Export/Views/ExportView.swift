import SwiftUI

struct ExportView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @State var exportAction: () -> Void
    @State var closeAction: () -> Void
    @State var searchText: String = .empty

    var body: some View {
        ModalSheet(title: L10n.export.capitalized) {
            CustomTextField(title: L10n.projectName.capitalized,
                               placeholder: L10n.projectNamePlaceholder.firstWordCapitalized,
                               text: $document.project.exportSettings.directoryName)
            HStack(alignment: .bottom) {
                    CustomTextField(title: L10n.exportPath.capitalized,
                                       placeholder: L10n.exportPathPlaceholder.firstWordCapitalized,
                                       text: $document.project.exportSettings.path)
                    RoundedButton<RoundedButtonSecondaryMediumStyle>(title: L10n.choose.capitalized,
                                                                   enabled: .constant(true)) {
                        document.selectExportFolder()
                    }
                }
            .padding(.bottom)
        } actionBarContent: {
            RoundedButton<RoundedButtonPrimaryMediumStyle>(title: L10n.export.capitalized,
                                                           enabled: .constant(true)) {
                exportAction()
            }
        } closeAction: {
                closeAction()
        }
    }
}
