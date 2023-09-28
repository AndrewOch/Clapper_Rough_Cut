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
            Table(of: FileSystemTableRowElement.self, selection: $selection) {
                TableColumn(L10n.fileTitle.firstWordCapitalized) { elem in
                    let element = elem.value
                    HStack(spacing: 8) {
                        if !element.isFile {
                            Button {
                                var updated = element
                                updated.collapsed = !updated.collapsed
                                document.project.updateFileSystemElement(withID: element.id, newValue: updated)
                            } label: {
                                Image(systemName: element.collapsed ? SystemImage.chevronRight.rawValue : SystemImage.chevronDown.rawValue)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 10, height: 10)
                            }
                            .focusable(false)
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 10, height: 10)
                                .background(.clear)
                        }
                        HStack(spacing: 5) {
                            FileIcon(type: element.type)
                                .scaledToFit()
                                .frame(width: 10, height: 10)
                            CustomLabel<BodyMediumStyle>(text: element.title)
                        }
                    }
                    .padding(.leading, (elem.nestingLevel - 1) * 20)
                }.width(min: 100, ideal: 200, max: 600)
                TableColumn(L10n.statuses.firstWordCapitalized) { elem in
                    let element = elem.value
                    HStack {
                        if element.statuses.contains(.transcription) {
                            TranscribedIcon()
                        }
                    }
                }.width(min: 30, ideal: 60, max: 80)
                TableColumn(L10n.duration.firstWordCapitalized) { elem in
                    let element = elem.value
                    if let duration = element.duration {
                        CustomLabel<BodyMediumStyle>(text: Formatter.formatDuration(duration: duration))
                    }
                }.width(min: 50, ideal: 100, max: 120)
                TableColumn(L10n.createdAt.firstWordCapitalized) { elem in
                    let element = elem.value
                    if let date = element.createdAt {
                        CustomLabel<BodyMediumStyle>(text: Formatter.formatDate(date: date))
                    }
                }.width(min: 40, ideal: 100, max: 200)
            } rows: {
                ForEach(fileSystemElements, id: \.self) { element in
                    TableRow(element)
                }
            }
            .font(.custom(FontFamily.Overpass.regular.name, size: 12))
            .scrollContentBackground(.hidden)
            .preferredColorScheme(.light)
            .tableStyle(.inset(alternatesRowBackgrounds: false))
            .background(Asset.light.swiftUIColor)
            .id(UUID())
        }
    }

    private var fileSystemElements: [FileSystemTableRowElement] {
        return fileSystemElements(from: document.project.fileSystem, nestingLevel: 0)
    }

    private func fileSystemElements(from container: FileSystemElement, nestingLevel: CGFloat) -> [FileSystemTableRowElement] {
        var result: [FileSystemTableRowElement] = []
        if nestingLevel > 0 {
            let currentElement = FileSystemTableRowElement(value: container, nestingLevel: nestingLevel)
            result.append(currentElement)
        }
        guard container.isContainer && !container.collapsed else { return result }
        for (_, subElement) in container.elements {
            let subElements = fileSystemElements(from: subElement, nestingLevel: nestingLevel + 1)
            result.append(contentsOf: subElements)
        }
        return result
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
