import SwiftUI

struct ExportView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @State var exportAction: () -> Void
    @State var closeAction: () -> Void
    @State var searchText: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Экспорт")
                    .foregroundColor(.black)
                    .bold()
                Spacer()
                Button(action: closeAction) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }.buttonStyle(PlainButtonStyle())
                    .focusable(false)
            }
            .padding(.bottom)
            VStack{
                HStack {
                    Text("Название проекта")
                        .foregroundColor(.black)
                    Spacer()
                }
                TextFieldComponent(placeholder: "Название проекта", text: $document.project.exportSettings.directoryName)
            }
            .padding(.bottom)
            VStack{
                HStack {
                    Text("Путь сохранения")
                        .foregroundColor(.black)
                    Spacer()
                }
                HStack {
                    TextFieldComponent(placeholder: "Путь сохранения", text: $document.project.exportSettings.path)
                    PrimaryButton(title: "Выбрать", accesibilityIdentifier: "", enabled: .constant(true)) {
                        document.selectExportFolder()
                    }
                }
            }
            .padding(.bottom)
            PrimaryButton(title: "Экспорт", accesibilityIdentifier: "", enabled: .constant(true)) {
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
