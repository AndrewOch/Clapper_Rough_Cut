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
            List(document.project.fileSystemListItems, children: \.elements, selection: $selection) { item in
                let element = item.value
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
                        drop(at: element, providers: providers)
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
            drop(at: document.project.fileSystem, providers: providers)
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
    
    func drop(at element: FileSystemElement, providers: [NSItemProvider]) -> Bool {
        var target: FileSystemElement? = nil
        if element.isContainer {
            target = element
        } else {
            target = document.project.firstFileSystemElement(where: { $0.id == element.containerId })
        }
        guard let target = target else { return false }
        if let itemProvider = providers.first {
            itemProvider.loadObject(ofClass: NSString.self) { items, _ in
                if let uuidString = items as? String {
                    var uuids: [UUID] = []
                    uuidString.components(separatedBy: ",").forEach { str in
                        if let uuid = UUID(uuidString: str) {
                            uuids.append(uuid)
                        }
                    }
                    uuids = uuids.filter({ id in
                        guard let elem = document.project.firstFileSystemElement(where: { $0.id == id }), let containerId = elem.containerId else { return true }
                        return !uuids.contains(where: { $0 == containerId })
                    })
                    guard !uuids.contains(target.id) else { return }
                    document.registerUndo()
                    for uuid in uuids {
                        document.project.moveFileSystemElement(withID: uuid, toFolderWithID: target.id)
                    }
                }
            }
        }
        return true
    }
}
