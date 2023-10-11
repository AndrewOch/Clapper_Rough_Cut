import SwiftUI

struct FileSystemView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @State private var width: CGFloat = 850
    @State private var fileSystemHeight: CGFloat = 600
    @State private var selection: Set<FileSystemElement.ID> = []

    @State private var draggable: [UUID] = []
    @State private var isTargeted = false

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
                FileSystemElementView(element: element)
                    .onDrag({
                        draggable.removeAll()
                        if selection.contains(element.id) {
                            draggable.append(contentsOf: selection)
                        } else {
                            draggable.append(element.id)
                        }
                        let uuidStrings = draggable.map { $0.uuidString }
                        return NSItemProvider(object: uuidStrings.joined(separator: ",") as NSItemProviderWriting)
                    }, preview: {
                            HStack(spacing: 2) {
                                FileIcon(type: element.type)
                                CustomLabel<BodyMediumStyle>(text: String(draggable.count))
                            }
                            .foregroundColor(Asset.dark.swiftUIColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Asset.white.swiftUIColor)
                            .cornerRadius(5)
                            .overlay(RoundedRectangle(cornerRadius: 5)
                                .stroke(Asset.accentLight.swiftUIColor, lineWidth: 1))
                    })
                    .onDrop(of: ["public.text", "public.uuid"], isTargeted: $isTargeted) { providers, _ in
                        guard element.isContainer else { return false }
                        if let itemProvider = providers.first {
                            itemProvider.loadObject(ofClass: NSString.self) { items, _ in
                                if let uuidString = items as? String {
                                    let uuids = uuidString.components(separatedBy: ",")
                                    document.registerUndo()
                                    for uuid in uuids {
                                        if let id = UUID(uuidString: uuid) {
                                            document.project.moveFileSystemElement(withID: id, toFolderWithID: element.id)
                                        }
                                    }
                                }
                            }
                        }
                        return true
                    }
                    .onHover { hover in
                        isTargeted = hover && element.isContainer
                    }
            }
        }
        .preferredColorScheme(.light)
        .font(.custom(FontFamily.Overpass.regular.name, size: 12))
        .scrollContentBackground(.hidden)
        .background(Asset.light.swiftUIColor)
        .onDrop(of: ["public.text", "public.uuid"], isTargeted: $isTargeted) { providers, _ in
            if let itemProvider = providers.first {
                itemProvider.loadObject(ofClass: NSString.self) { items, _ in
                    if let uuidString = items as? String {
                        let uuids = uuidString.components(separatedBy: ",")
                        document.registerUndo()
                        for uuid in uuids {
                            if let id = UUID(uuidString: uuid) {
                                document.project.moveFileSystemElement(withID: id,
                                                                       toFolderWithID: document.project.fileSystem.id)
                            }
                        }
                    }
                }
            }
            return true
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
