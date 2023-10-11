import Foundation

struct RoughCutProject: Identifiable, Codable {
    var id = UUID()
    var scriptFile: ScriptFile?
    var fileSystem: FileSystemElement = FileSystemElement(title: .empty, type: .folder)
    var elements: [UUID: FileSystemElement] = [:]
    var exportSettings: ExportSettings = ExportSettings()
}

// MARK: - Project states
extension RoughCutProject {
    var hasUntranscribedFiles: Bool {
        return findAllFileSystemElements(where: { $0.isFile && $0.transcription == nil }).isNotEmpty
    }
    var hasUnsortedTranscribedFiles: Bool {
        return findAllFileSystemElements(where: { $0.isFile && $0.transcription != nil }).isNotEmpty
    }
    var canSortScenes: Bool {
        return hasUntranscribedFiles && scriptFile != nil
    }
    var hasUnmatchedSortedFiles: Bool {
        firstFileSystemElement { scene in
            scene.isScene &&
            firstFileSystemElement(where: { $0.containerId == scene.id && $0.type == .audio }) != nil &&
            firstFileSystemElement(where: { $0.containerId == scene.id && $0.type == .video }) != nil
        } != nil
    }
}

// MARK: - FileSystem Utilities
extension RoughCutProject {
    func firstFileSystemElement(where predicate: (FileSystemElement) -> Bool) -> FileSystemElement? {
        return elements.values.first(where: predicate)
    }

    func findAllFileSystemElements(where predicate: (FileSystemElement) -> Bool) -> [FileSystemElement] {
        return elements.values.filter(predicate)
    }

    mutating func addElement(_ newElement: FileSystemElement) {
        var newElement = newElement
        newElement.containerId = fileSystem.id
        elements[newElement.id] = newElement
    }

    mutating func addElement(_ newElement: FileSystemElement, toFolderWithID folderID: UUID) {
        if fileSystem.id == folderID {
            addElement(newElement)
            return
        }
        guard var targetFolder = firstFileSystemElement(where: { $0.id == folderID }) else { return }
        var newElement = newElement
        newElement.containerId = targetFolder.id
        elements[newElement.id] = newElement
    }

    mutating func updateFileSystemElement(withID elementID: UUID,
                                          newValue: FileSystemElement) {
        elements[elementID] = newValue
    }

    func getContainer(forElementWithID elementID: UUID) -> FileSystemElement? {
        guard let element = firstFileSystemElement(where: { $0.id == elementID }) else { return nil }
        if fileSystem.id == element.containerId { return fileSystem }
        for elem in elements {
            if elem.key == element.containerId { return elem.value }
        }
        return nil
    }

    mutating func deleteFileSystemElement(by elementID: UUID) -> Bool {
        guard let elem = elements.removeValue(forKey: elementID) else { return false }
        return true
    }

    mutating func moveFileSystemElement(withID elementID: UUID, toFolderWithID folderID: UUID) {
        guard let elementToMove = firstFileSystemElement(where: { $0.id == elementID }) else { return }
        _ = deleteFileSystemElement(by: elementToMove.id)
        addElement(elementToMove, toFolderWithID: folderID)
    }
}

// MARK: - Convert FileSystem to ListItems
extension RoughCutProject {
    var fileSystemListItems: [FileSystemListItem] {
        var items: [FileSystemListItem] = []
        findAllFileSystemElements(where: { $0.containerId == fileSystem.id }).forEach { elem in
            items.append(fileSystemListItem(element: elem))
        }
        return items
    }

    private func fileSystemListItem(element: FileSystemElement) -> FileSystemListItem {
        var elems: [FileSystemListItem] = []
        findAllFileSystemElements(where: { $0.containerId == element.id }).forEach { elem in
            elems.append(fileSystemListItem(element: elem))
        }
        if elems.isNotEmpty {
            return FileSystemListItem(value: element, elements: elems)
        }
        return FileSystemListItem(value: element, elements: nil)
    }
}

extension RoughCutProject {
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
