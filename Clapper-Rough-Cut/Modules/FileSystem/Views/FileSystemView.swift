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
            List(document.project.fileSystem.elements ?? [], children: \.elements, selection: $selection) { element in
                HStack(alignment: .center) {
                    HStack(spacing: 5) {
                        FileIcon(type: element.type)
                            .frame(width: 10, height: 10)
                            .scaledToFit()
                        CustomLabel<BodyMediumStyle>(text: element.title)
                    }
                    Spacer()
                    HStack {
                        if element.statuses.contains(.transcription) {
                            TranscribedIcon()
                        }
                    }
                    .frame(width: 60)
                    HStack {
                        if let duration = element.duration {
                            CustomLabel<BodyMediumStyle>(text: Formatter.formatDuration(duration: duration))
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                    .frame(width: 60)
                    HStack {
                        if let date = element.createdAt {
                            CustomLabel<BodyMediumStyle>(text: Formatter.formatDate(date: date))
                                .lineLimit(1)
                        }
                        Spacer()
                    }.frame(width: 200)
                }
                .padding(.horizontal)
            }
            .preferredColorScheme(.light)
            .font(.custom(FontFamily.Overpass.regular.name, size: 12))
            .scrollContentBackground(.hidden)
            .background(Asset.light.swiftUIColor)
        }
    }

    var detailView: some View {
        VStack {
            if selection.count > 1 {
                SeveralSelectionDetailView(selection: $selection)
            } else {
                if let id = selection.first, let element = document.project.firstFileSystemElement(where: { $0.id == id }) {
                    FileSystemSelectionDetailView(element: Binding(get: { return element },
                                                                   set: { document.project.updateFileSystemElement(withID: element.id, newValue: $0) }))
                }
            }
            Spacer()
        }
    }
}

struct FileSystemTableRowElement: Identifiable, Hashable {
    let id: UUID
    let value: FileSystemElement
    let nestingLevel: CGFloat

    init(value: FileSystemElement, nestingLevel: CGFloat) {
        self.id = value.id
        self.value = value
        self.nestingLevel = nestingLevel
    }
}
