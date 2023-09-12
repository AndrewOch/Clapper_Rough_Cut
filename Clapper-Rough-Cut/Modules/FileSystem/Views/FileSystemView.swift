import SwiftUI

struct FileSystemView: View {

    @EnvironmentObject var document: ClapperRoughCutDocument
    @State private var width: CGFloat = 850
    @State private var fileSystemHeight: CGFloat = 600

    var body: some View {
        VSplitView {
            fileSystem
                .frame(minWidth: 850, idealWidth: width, maxWidth: .infinity)
                .frame(minHeight: 400, idealHeight: fileSystemHeight, maxHeight: .infinity)
                    .onAppear {
                        width = 850
                        fileSystemHeight = 600
                    }
            detailView
                .padding()
                    .frame(minWidth: 850, idealWidth: width, maxWidth: .infinity)
                    .frame(minHeight: 200, maxHeight: .infinity)
                    .background(Asset.semiWhite.swiftUIColor)
        }
    }

    var fileSystem: some View {
        VStack {
            ZStack {
                Asset.light.swiftUIColor
                ScrollView {
                    LazyVStack(spacing: 0) {
                        RawFilesFolderView(folder: document.project.unsortedFolder,
                                           collapsed: document.project.unsortedFolder.collapsed,
                                           selected: document.project.selectedFolder == document.project.unsortedFolder)
                        ForEach(document.project.phraseFolders) { folder in
                            RawFilesFolderView(folder: folder, collapsed: folder.collapsed, selected: document.project.selectedFolder == folder)
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
        }
    }

    var detailView: some View {
        VStack {
            if document.project.selectedFile != nil {
                RawFileDetailView(file: $document.project.selectedFile)
            } else if document.project.selectedFolder != nil {
                RawFolderDetailView(folder: $document.project.selectedFolder)
            } else if document.project.selectedTake != nil {
                RawTakeDetailView(take: $document.project.selectedTake)
            }
            Spacer()
        }
    }
}

struct FileSystemView_Previews: PreviewProvider {
    static var previews: some View {
        FileSystemView()
    }
}
