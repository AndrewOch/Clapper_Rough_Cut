import SwiftUI

struct ExportView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @State var exportAction: () -> Void
    @State var closeAction: () -> Void
    @State var searchText: String = .empty

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(L10n.export.capitalized)
                    .foregroundColor(.black)
                    .bold()
                Spacer()
                Button(action: closeAction) {
                    SystemImage.xmark.imageView
                        .foregroundColor(.black)
                }.buttonStyle(PlainButtonStyle())
                    .focusable(false)
            }
            .padding(.bottom)
            VStack {
                HStack {
                    Text(L10n.projectName.capitalized)
                        .foregroundColor(.black)
                    Spacer()
                }
                TextFieldComponent(placeholder: L10n.projectName.capitalized, text: $document.project.exportSettings.directoryName)
            }
            .padding(.bottom)
            VStack {
                HStack {
                    Text(L10n.exportPath.capitalized)
                        .foregroundColor(.black)
                    Spacer()
                }
                HStack {
                    TextFieldComponent(placeholder: L10n.exportPath.capitalized, text: $document.project.exportSettings.path)
                    RoundedButton<RoundedButtonPrimaryMediumStyle>(title: L10n.choose.capitalized,
                                                                   enabled: .constant(true)) {
                        document.selectExportFolder()
                    }
                }
            }
            .padding(.bottom)
            RoundedButton<RoundedButtonPrimaryMediumStyle>(title: L10n.export.capitalized,
                                                           enabled: .constant(true)) {
                exportAction()
            }
            Spacer()
        }
        .padding()
        .frame(minWidth: 500, idealWidth: 500, maxWidth: .infinity)
        .background(.white)
        .cornerRadius(10)
    }
}
