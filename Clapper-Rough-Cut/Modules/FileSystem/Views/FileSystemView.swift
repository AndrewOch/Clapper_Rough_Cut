import SwiftUI

struct FileSystemView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @State private var width: CGFloat = 850
    @State private var fileSystemHeight: CGFloat = 600
    @State private var selection: Set<FileSystemElement.ID> = []

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
        ZStack {
            Asset.light.swiftUIColor
            let elementsArray = Array(document.project.fileSystem.elements.values)
            Table(of: FileSystemElement.self, selection: $selection) {
                TableColumn(L10n.fileTitle.firstWordCapitalized) { element in
                    HStack {
                        FileIcon(type: element.type)
                        Text(element.title)
                    }
                }.width(min: 100, ideal: 200, max: 600)
                TableColumn(L10n.statuses.firstWordCapitalized) { element in
                    HStack {
                        if element.statuses.contains(.transcription) {
                            TranscribedIcon()
                        }
                    }
                }.width(min: 30, ideal: 60, max: 80)
                TableColumn(L10n.duration.firstWordCapitalized) { element in
                    if let duration = element.duration {
                        Text(Formatter.formatDuration(duration: duration))
                    }
                }.width(min: 50, ideal: 100, max: 120)
                TableColumn(L10n.createdAt.firstWordCapitalized) { element in
                    if let date = element.createdAt {
                        Text(Formatter.formatDate(date: date))
                    }
                }.width(min: 40, ideal: 100, max: 200)
            } rows: {
                ForEach(elementsArray) { element in
                    TableRow(element)
                }
            }
            .scrollContentBackground(.hidden)
            .preferredColorScheme(.light)
            .tableStyle(.inset(alternatesRowBackgrounds: false))
            .background(Asset.light.swiftUIColor)
        }
    }

    func fileSystemElementTableRow(folder: FileSystemElement) -> some TableRowContent {
        TableRow(folder)
    }

    var detailView: some View {
        VStack {
            //TODO: - Detailed view
//            if document.project.selectedFile != nil {
//                RawFileDetailView(file: $document.project.selectedFile)
//            } else if document.project.selectedFolder != nil {
//                RawFolderDetailView(folder: $document.project.selectedFolder)
//            } else if document.project.selectedTake != nil {
//                RawTakeDetailView(take: $document.project.selectedTake)
//            }
            Spacer()
        }
    }
}
