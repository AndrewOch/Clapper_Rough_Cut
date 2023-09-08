import SwiftUI

struct FileSystemView: View {

    @EnvironmentObject var document: ClapperRoughCutDocument
    @State private var width: CGFloat = 850
    @State private var fileSystemHeight: CGFloat = 600
    @State private var isExportViewPresented = false

    var body: some View {
        VSplitView {
            fileSystem
                .frame(minWidth: 850, idealWidth: width, maxWidth: .infinity)
                .frame(minHeight: 400, idealHeight: fileSystemHeight, maxHeight: .infinity)
                    .background(Color.white)
                    .onAppear {
                        width = 850
                        fileSystemHeight = 600
                    }
                    .sheet(isPresented: $isExportViewPresented) {
                        ExportView {
                            document.export()
                            isExportViewPresented.toggle()
                        } closeAction: {
                            isExportViewPresented.toggle()
                        }
                    }
            detailView
                .padding()
                    .frame(minWidth: 850, idealWidth: width, maxWidth: .infinity)
                    .frame(minHeight: 200, maxHeight: .infinity)
                    .background(Color.white)
        }
    }

    var fileSystem: some View {
        VStack {
            HStack {
                RoundedButton<RoundedButtonPrimaryMediumStyle>(title: L10n.addFiles.capitalized,
                                                               imageName: SystemImage.squareAndArrowDown.rawValue,
                                                               enabled: .constant(true)) {
                    document.addRawFiles()
                }
                RoundedButton<RoundedButtonPrimaryMediumStyle>(title: L10n.transcribe.capitalized,
                                                               imageName: SystemImage.rectangleAndPencilAndEllipsis.rawValue,
                              enabled: $document.project.hasUntranscribedFiles) {
                    document.transcribeFiles()
                }
                RoundedButton<RoundedButtonPrimaryMediumStyle>(title: L10n.determineScenes.capitalized,
                                                               imageName: SystemImage.film.rawValue,
                                                               enabled: $document.project.canSortScenes) {
                    document.matchScenes()
                }
                RoundedButton<RoundedButtonPrimaryMediumStyle>(title: L10n.determineTakes.capitalized,
                                                               imageName: SystemImage.filmStack.rawValue,
                                                               enabled: $document.project.hasUnmatchedSortedFiles) {
                    document.matchTakes()
                }
                RoundedButton<RoundedButtonPrimaryMediumStyle>(title: L10n.export.capitalized,
                                                               imageName: SystemImage.rectanglePortraitAndArrowRight.rawValue,
                                                               enabled: .constant(true)) {
                    isExportViewPresented.toggle()
                }
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)
            ZStack {
                Color.black.opacity(0.8)
                ScrollView {
                    LazyVStack {
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
