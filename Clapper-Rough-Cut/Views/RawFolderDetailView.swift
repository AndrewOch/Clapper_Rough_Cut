import SwiftUI

struct RawFolderDetailView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @Binding var folder: RawFilesFolder?
    @State private var isModalPresented = false
    
    var body: some View {
        if let folder = folder {
                HStack {
                    Image(systemName: "folder")
                        .foregroundColor(.gray)
                    Text(folder.title)
                        .foregroundColor(.gray)
                    Spacer()
                    if document.project.unsortedFolder != folder {
                        PrimaryButton(title: "Заменить сцену",
                                      imageName: "film",
                                      accesibilityIdentifier: "",
                                      enabled: .constant(true)) {
                            isModalPresented.toggle()
                        }
                    }
                }
                .sheet(isPresented: $isModalPresented) {
                    SelectPhraseMatchView() { phrase in
                        document.changeScene(for: folder, phrase: phrase)
                        isModalPresented.toggle()
                    } closeAction: {
                        isModalPresented.toggle()
                    }
                }
                
                HStack {
                    FileIcon(type: .video)
                    Text("\(folder.files.filter({ file in file.type == .video }).count) видео")
                    Spacer()
                }
                .foregroundColor(.black)
                .padding(.vertical, 5)
                HStack{
                    FileIcon(type: .audio)
                    Text("\(folder.files.filter({ file in file.type == .audio }).count) аудио")
                    Spacer()
                }
                .foregroundColor(.black)
                .padding(.vertical, 5)
                HStack{
                    Image(systemName: "film.stack")
                    Text("\(folder.takes.count) дубли")
                    Spacer()
                }
                .foregroundColor(.black)
                .padding(.vertical, 5)
        }
    }
}
