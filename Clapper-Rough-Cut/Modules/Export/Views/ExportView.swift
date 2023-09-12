import SwiftUI

struct ExportView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @State var exportAction: () -> Void
    @State var closeAction: () -> Void
    @State var searchText: String = .empty

    var body: some View {
        ModalSheet(title: L10n.export.capitalized) {
            VStack {
                HStack {
                    Label<BodyMediumStyle>(text: L10n.projectName.capitalized)
                        .foregroundColor(Asset.dark.swiftUIColor)
                    Spacer()
                }
                TextFieldComponent(placeholder: L10n.projectName.capitalized, text: $document.project.exportSettings.directoryName)
            }
            .padding(.bottom)
            VStack {
                HStack {
                    Label<BodyMediumStyle>(text: L10n.exportPath.capitalized)
                        .foregroundColor(Asset.dark.swiftUIColor)
                    Spacer()
                }
                HStack {
                    TextFieldComponent(placeholder: L10n.exportPath.capitalized, text: $document.project.exportSettings.path)
                    RoundedButton<RoundedButtonSecondaryMediumStyle>(title: L10n.choose.capitalized,
                                                                   enabled: .constant(true)) {
                        document.selectExportFolder()
                    }
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
