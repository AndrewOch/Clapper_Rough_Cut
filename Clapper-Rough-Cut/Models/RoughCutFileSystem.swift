import Foundation

struct RoughCutFileSystem: Identifiable, Codable {
    var id = UUID()

    var root: FileSystemElement {
        return _root
    }

    private var _root: FileSystemElement = FileSystemElement(title: .empty, type: .folder)
    private var elements: [UUID: FileSystemElement] = [:]
}

// MARK: - FileSystem Utilities
extension RoughCutFileSystem {
    func elementById(_ id: UUID) -> FileSystemElement? {
        return elements[id]
    }

    func firstElement(where predicate: (FileSystemElement) -> Bool) -> FileSystemElement? {
        return elements.values.first(where: predicate)
    }

    func allElements(where predicate: (FileSystemElement) -> Bool) -> [FileSystemElement] {
        return elements.values.filter(predicate)
    }

    mutating func addElement(_ newElement: FileSystemElement) {
        var newElement = newElement
        newElement.containerId = _root.id
        elements[newElement.id] = newElement
    }

    mutating func addElement(_ newElement: FileSystemElement, toFolderWithID folderID: UUID) {
        if _root.id == folderID {
            addElement(newElement)
            return
        }
        guard let targetFolder = firstElement(where: { $0.id == folderID }) else { return }
        var newElement = newElement
        newElement.containerId = targetFolder.id
        elements[newElement.id] = newElement
    }

    mutating func updateElement(withID elementID: UUID,
                                          newValue: FileSystemElement) {
        elements[elementID] = newValue
    }

    func getContainer(forElementWithID elementID: UUID) -> FileSystemElement? {
        guard let element = firstElement(where: { $0.id == elementID }) else { return nil }
        if _root.id == element.containerId { return _root }
        return elements.first(where: { $0.key == element.containerId })?.value
    }

    func contains(_ elementId: UUID, in folderID: UUID) -> Bool {
        guard var currentElement = elements[elementId] else { return false }
        if folderID == _root.id { return true }
        while currentElement.id != _root.id {
            guard let containerId = currentElement.containerId else { return false }
            if containerId == folderID { return true }
            guard let container = elements[containerId] else { return false }
            currentElement = container
        }
        return false
    }

    mutating func deleteElement(by elementID: UUID) -> Bool {
        guard elements.removeValue(forKey: elementID) != nil else { return false }
        return true
    }

    mutating func moveElement(withID elementID: UUID, toFolderWithID folderID: UUID) {
        elements[elementID]?.containerId = folderID
    }
}

extension RoughCutFileSystem {
    func generateUniqueName(baseName: String) -> String {
        var uniqueName = baseName
        var folderNumber = 1
        while elements.values.contains(where: { $0.title == uniqueName }) {
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
        return items
    }

    private func listItem(element: FileSystemElement) -> FileSystemListItem {
        var elems: [FileSystemListItem] = []
        allElements(where: { $0.containerId == element.id }).forEach { elem in
            elems.append(listItem(element: elem))
        }
        if elems.isNotEmpty {
            return FileSystemListItem(value: element, elements: elems)
        }
        return FileSystemListItem(value: element, elements: nil)
    }
}
