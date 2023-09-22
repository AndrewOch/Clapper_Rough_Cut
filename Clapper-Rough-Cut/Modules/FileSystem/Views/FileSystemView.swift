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
        ZStack {
            Asset.light.swiftUIColor
            let elementsArray = Array(document.project.fileSystem.elements.values)
            Table(elementsArray) {
                TableColumn("Название", value: \.title)
                    .width(min: 100, ideal: 200, max: 600)
                TableColumn("Длительность", value: \.title)
                    .width(min: 40, ideal: 100, max: 200)
                TableColumn("Дата создания") { element in
                    if let date = element.createdAt {
                        Text(Formatter.formatDate(date: date))
                    }
                }
                .width(min: 40, ideal: 100, max: 200)
            }
            .scrollContentBackground(.hidden)
            .tableStyle(.bordered(alternatesRowBackgrounds: false))
            .background(Asset.light.swiftUIColor)
        }
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
