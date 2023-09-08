import SwiftUI

struct RawFilesFolderView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @State var folder: RawFilesFolder
    @State var collapsed: Bool
    var selected: Bool
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    collapsed.toggle()
                } label: {
                    Image(systemName: collapsed ? "chevron.right" : "chevron.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 8, height: 8)
                }
                .focusable(false)
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    document.selectFolder(folder)
                }, label: {
                    Image(systemName: "folder")
                    Text(folder.title).lineLimit(1)
                    Spacer()
                })
                .focusable(false)
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 5)
                .padding(.vertical, selected ? 5 : 1)
                .background(selected ? Color.purple.opacity(0.3) : Color.clear)
                .cornerRadius(5)
            }
            if !collapsed {
                ForEach(folder.takes) { take in
                    RawTakeView(video: take.video,
                                audio: take.audio,
                                action: {
                        document.selectTake(take)
                    }, selected: document.project.selectedTake?.id == take.id)
                    .padding(.leading, 20)
                }
                ForEach(folder.files) { file in
                    RawFileView(file: file, action: {
                        document.selectFile(file)
                    }, selected: document.project.selectedFile?.id == file.id)
                    .padding(.leading, 20)
                }
            }
        }
        .padding(.vertical, 10)
    }
}
