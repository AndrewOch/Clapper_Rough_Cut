import SwiftUI
import KeyboardShortcuts

struct FileSystemView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var document: ClapperRoughCutDocument
    @State private var width: CGFloat = 850
    @State private var fileSystemHeight: CGFloat = 400
    @State private var selection: Set<FileSystemElement.ID> = []
    @State private var draggable: [UUID] = []
    @State private var isTargeted = false
    @State private var currentPlayerTime: Double = 0
    @State private var searchText: String = .empty
    @FocusState private var searchBarIsFocused: Bool

    var body: some View {
        VSplitView {
            fileSystem
                .frame(minWidth: 850, idealWidth: width, maxWidth: .infinity)
                .frame(minHeight: 400, idealHeight: fileSystemHeight, maxHeight: .infinity)
                .onAppear {
                    width = 850
                    fileSystemHeight = 400
                }
            HSplitView {
                if selection.count == 1,
                   let elementId = selection.first,
                   let element = document.project.fileSystem.elementById(elementId) {
                    if element.isFile {
                        MediaPlayerView(element: .getOnly(element), currentTime: $currentPlayerTime)
                            .frame(minWidth: 300, idealWidth: 600, maxWidth: 600)
                    }
                }
                detailView
                    .padding()
                    .frame(minWidth: 350, idealWidth: 350, maxWidth: .infinity)
                    .background(Color.surfaceSecondary(colorScheme))
            }
            .frame(minWidth: 850, idealWidth: width, maxWidth: .infinity)
            .frame(minHeight: 200, idealHeight: 400, maxHeight: .infinity)
        }
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.keyCode == 51 && !searchBarIsFocused {
                    document.deleteSelectedFiles(selection)
                    selection = []
                    return event
                }
                if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "t" {
                    document.transcribeSelectedFiles(selection)
                    return nil
                }
                return event
            }
        }
    }

    var fileSystem: some View {
        ZStack {
            Color.surfaceTertiary(colorScheme)
            VStack {
                HStack {
                    Spacer()
                    CustomSearchTextField(placeholder: L10n.search.firstWordCapitalized,
                                    text: $searchText)
                    .frame(width: 300)
                    .focused($searchBarIsFocused)
                }
                .padding(.horizontal, 10)
                List(document.project.fileSystem.filteredItems(searchText: searchText),
                     children: \.elements,
                     selection: $selection) { item in
                    let element = item.value
                    FileSystemListItemView(item: .getOnly(item))
                        .onDrag({
                            onDrag(element)
                        }, preview: {
                            dragPreview
                        })
                        .onDrop(of: [.typeText, .typeUUID], isTargeted: $isTargeted) { providers, _ in
                            drop(at: element, providers: providers)
                        }
                        .onHover { hover in
                            isTargeted = hover && element.isContainer
                        }
                }
            }
            .padding(.vertical, 10)
        }
        .font(.custom(FontFamily.Overpass.regular.name, size: 12))
        .scrollContentBackground(.hidden)
        .background(Color.surfaceTertiary(colorScheme))
        .onDrop(of: [.typeText, .typeUUID], isTargeted: $isTargeted) { providers, _ in
            drop(at: document.project.fileSystem.root, providers: providers)
        }
        .onTapGesture {
            document.states.selectedHeaderOption = .none
        }
        .sheet(isPresented: $document.states.isAddFilesViewPresented) {
            AddFilesView { elements, device in
                for var element in elements {
                    element.deviceId = device.id
                    document.project.fileSystem.addElement(element)
                }
                document.project.devices.append(device)
                document.states.isAddFilesViewPresented.toggle()
            } closeAction: {
                document.states.isAddFilesViewPresented.toggle()
            }
        }
    }

    var detailView: some View {
        VStack {
            if selection.count > 1 {
                SeveralSelectionDetailView(selection: $selection)
            } else {
                if let id = selection.first, let element = document.project.fileSystem.elementById(id) {
                    FileSystemSelectionDetailView(element: Binding(get: { element },
                                                                   set: { document.project.fileSystem.updateElement(withID: element.id,
                                                                                                                    newValue: $0) }), currentTime: $currentPlayerTime)
                }
            }
            Spacer()
        }
    }

    var dragPreview: some View {
        HStack(spacing: 2) {
            FileIcon(type: .folder)
            CustomLabel<BodyMediumStyle>(text: String(draggable.count))
        }
        .foregroundColor(.contentPrimary(colorScheme))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.surfacePrimary(colorScheme))
        .cornerRadius(5)
        .overlay(RoundedRectangle(cornerRadius: 5)
            .stroke(Asset.accentLight.swiftUIColor, lineWidth: 1))
    }

    func onDrag(_ element: FileSystemElement) -> NSItemProvider {
        draggable.removeAll()
        if selection.contains(element.id) {
            draggable.append(contentsOf: selection)
        } else {
            draggable.append(element.id)
        }
        let uuidStrings = draggable.map { $0.uuidString }
        return NSItemProvider(object: uuidStrings.joined(separator: ",") as NSItemProviderWriting)
    }

    func drop(at element: FileSystemElement, providers: [NSItemProvider]) -> Bool {
        var target: FileSystemElement? = nil
        if element.isContainer {
            target = element
        } else {
            target = document.project.fileSystem.getContainer(forElementWithID: element.id)
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
                        guard let elem = document.project.fileSystem.elementById(id), let containerId = elem.containerId else { return true }
                        return !uuids.contains(where: { $0 == containerId }) && !document.project.fileSystem.contains(target.id,
                                                                                                                      in: id)
                    })
                    guard !uuids.contains(target.id) else { return }
                    document.registerUndo()
                    for uuid in uuids {
                        document.project.fileSystem.moveElement(withID: uuid, toFolderWithID: target.id)
                    }
                }
            }
        }
        return true
    }
}
