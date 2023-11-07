import Foundation

struct RoughCutFileSystem: Identifiable, Codable {
    var id = UUID()

    var root: FileSystemElement {
        return _root
    }

    var keys: [UUID] {
        Array(_elements.keys)
    }

    var elements: [FileSystemElement] {
        Array(_elements.values)
    }

    private var _root: FileSystemElement = FileSystemElement(title: .empty, type: .folder)
    private var _elements: [UUID: FileSystemElement] = [:]
}

// MARK: - FileSystem Utilities
extension RoughCutFileSystem {
    func elementById(_ id: UUID) -> FileSystemElement? {
        return _elements[id]
    }

    func firstElement(where predicate: (FileSystemElement) -> Bool) -> FileSystemElement? {
        return _elements.values.first(where: predicate)
    }

    func allElements(where predicate: (FileSystemElement) -> Bool) -> [FileSystemElement] {
        return _elements.values.filter(predicate)
    }

    mutating func addElement(_ newElement: FileSystemElement) {
        var newElement = newElement
        newElement.containerId = _root.id
        _elements[newElement.id] = newElement
    }

    mutating func addElement(_ newElement: FileSystemElement, toFolderWithID folderID: UUID) {
        if _root.id == folderID {
            addElement(newElement)
            return
        }
        guard let targetFolder = firstElement(where: { $0.id == folderID }) else { return }
        var newElement = newElement
        newElement.containerId = targetFolder.id
        _elements[newElement.id] = newElement
    }

    mutating func updateElement(withID elementID: UUID,
                                          newValue: FileSystemElement) {
        _elements[elementID] = newValue
    }

    func getContainer(forElementWithID elementID: UUID) -> FileSystemElement? {
        guard let element = firstElement(where: { $0.id == elementID }) else { return nil }
        if _root.id == element.containerId { return _root }
        return _elements.first(where: { $0.key == element.containerId })?.value
    }

    func contains(_ elementId: UUID, in folderID: UUID) -> Bool {
        guard var currentElement = _elements[elementId] else { return false }
        if folderID == _root.id { return true }
        while currentElement.id != _root.id {
            guard let containerId = currentElement.containerId else { return false }
            if containerId == folderID { return true }
            guard let container = _elements[containerId] else { return false }
            currentElement = container
        }
        return false
    }

    mutating func deleteElement(by elementID: UUID) -> Bool {
        guard let element = _elements.removeValue(forKey: elementID) else { return false }
        allElements(where: { $0.containerId == element.id }).forEach { elem in
            _ = deleteElement(by: elem.id)
        }
        return true
    }

    mutating func moveElement(withID elementID: UUID, toFolderWithID folderID: UUID) {
        _elements[elementID]?.containerId = folderID
    }
}

extension RoughCutFileSystem {
    func generateUniqueName(baseName: String) -> String {
        var uniqueName = baseName
        var folderNumber = 1
        while _elements.values.contains(where: { $0.title == uniqueName }) {
            folderNumber += 1
            uniqueName = "\(baseName) \(folderNumber)"
        }

        return uniqueName
    }
}

// MARK: - Convert FileSystem to ListItems
extension RoughCutFileSystem {
    var listItems: [FileSystemListItem] {
        var items: [FileSystemListItem] = []
        allElements(where: { $0.containerId == _root.id }).forEach { elem in
            items.append(listItem(element: elem))
        }
        return items.sorted(by: <)
    }

    private func listItem(element: FileSystemElement) -> FileSystemListItem {
        var elems: [FileSystemListItem] = []
        allElements(where: { $0.containerId == element.id }).forEach { elem in
            elems.append(listItem(element: elem))
        }
        if elems.isNotEmpty {
            return FileSystemListItem(value: element, elements: elems.sorted(by: <))
        }
        return FileSystemListItem(value: element, elements: nil)
    }

    func filteredItems(searchText: String) -> [FileSystemListItem] {
        if searchText.isEmpty {
            return listItems
        } else {
            let items = _elements.map { _, value in
                return FileSystemListItem(value: value, elements: nil)
            }
            var filtered: [FileSystemListItem] = []
            items.forEach { item in
                var item = item
                var chosen = false
                if item.value.type.stringValue.localizedCaseInsensitiveContains(searchText) {
                    chosen = true
                    item.highlights.append(.type)
                }
                if item.value.title.localizedCaseInsensitiveContains(searchText) {
                    chosen = true
                    item.highlights.append(.title)
                }
                if let subtitles = item.value.fullSubtitles, subtitles.localizedCaseInsensitiveContains(searchText) {
                    chosen = true
                    item.highlights.append(.subtitles)
                }
                if chosen {
                    filtered.append(item)
                }
            }
            return filtered
        }
    }
}
