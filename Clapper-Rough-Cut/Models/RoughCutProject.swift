import Foundation

struct RoughCutProject: Identifiable, Codable {
    var id = UUID()
    var scriptFile: ScriptFile?
    var fileSystem: FileSystemElement = FileSystemElement(title: .empty, type: .folder, elements: [])
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
        firstFileSystemElement(where: { $0.isScene &&
            (($0.elements?.contains(where: { $0.type == .audio })) != nil) &&
            (($0.elements?.contains(where: { $0.type == .video })) != nil) }) != nil
    }
}

// MARK: - FileSystem Utilities
extension RoughCutProject {
    func firstFileSystemElement(where predicate: (FileSystemElement) -> Bool,
                                excludeScenes: Bool = false,
                                excludeTakes: Bool = false,
                                recursiveSearch: Bool = true) -> FileSystemElement? {
        if predicate(fileSystem) { return fileSystem }
        return firstFileSystemElement(from: fileSystem,
                                      where: predicate,
                                      excludeScenes: excludeScenes,
                                      excludeTakes: excludeTakes,
                                      recursiveSearch: recursiveSearch)
    }

    private func firstFileSystemElement(from folder: FileSystemElement,
                                        where predicate: (FileSystemElement) -> Bool,
                                        excludeScenes: Bool = false,
                                        excludeTakes: Bool = false,
                                        recursiveSearch: Bool = true) -> FileSystemElement? {

        if let element = folder.elements?.first(where: predicate) {
            return element
        }
        var result: FileSystemElement? = nil
        guard let elements = folder.elements else { return result }
        for element in elements {
            guard recursiveSearch || (!excludeScenes && element.isScene) || (!excludeTakes && element.isTake) else {
                continue
            }
            result = firstFileSystemElement(from: element,
                                                      where: predicate,
                                                      excludeScenes: excludeScenes,
                                                      excludeTakes: excludeTakes,
                                                      recursiveSearch: recursiveSearch)
            if result != nil { break }
        }
        return result
    }

    func findAllFileSystemElements(where predicate: (FileSystemElement) -> Bool,
                                   excludeScenes: Bool = false,
                                   excludeTakes: Bool = false,
                                   recursiveSearch: Bool = true) -> [FileSystemElement] {
        let files: [FileSystemElement] = findAllFileSystemElements(from: fileSystem,
                                                               where: predicate,
                                                               excludeScenes: excludeScenes,
                                                               excludeTakes: excludeTakes,
                                                               recursiveSearch: recursiveSearch)
        return files
    }

    private func findAllFileSystemElements(from folder: FileSystemElement,
                             where predicate: (FileSystemElement) -> Bool,
                             excludeScenes: Bool = false,
                             excludeTakes: Bool = false,
                             recursiveSearch: Bool = true) -> [FileSystemElement] {
        guard var files = folder.elements?.filter(predicate) else { return [] }
        files.forEach { element in
            guard recursiveSearch || (!excludeScenes && element.isScene) || (!excludeTakes && element.isTake) else {
                return
            }
            files.append(contentsOf: findAllFileSystemElements(from: element,
                                                 where: predicate,
                                                 excludeScenes: excludeScenes,
                                                 excludeTakes: excludeTakes,
                                                 recursiveSearch: recursiveSearch))
        }
        return files
    }

    mutating func addElement(_ newElement: FileSystemElement) {
        fileSystem.elements?.append(newElement)
    }

    mutating func addElement(_ newElement: FileSystemElement, toFolderWithID folderID: UUID) {
        guard var targetFolder = firstFileSystemElement(where: { $0.id == folderID }) else {
            return
        }
        targetFolder.elements?.append(newElement)
        updateFileSystemElement(withID: targetFolder.id, newValue: targetFolder)
    }

    mutating func updateFileSystemElement(withID elementID: UUID,
                                          newValue: FileSystemElement) {
        guard var updated = fileSystem.elements else { return }
        _ = updateFileSystemElement(withID: elementID, newValue: newValue, in: &updated)
        fileSystem.elements = updated
    }

    private func updateFileSystemElement(withID elementID: UUID,
                                         newValue: FileSystemElement,
                                         in elements: inout [FileSystemElement]) -> Bool {
        if let index = elements.firstIndex(where: { $0.id == elementID }) {
            elements[index] = newValue
            return true
        }
        for (index, element) in elements.enumerated() where element.elements != nil {
            if updateFileSystemElement(withID: elementID, newValue: newValue, in: &elements[index].elements!) {
                return true
            }
        }
        return false
    }

    func getContainer(forElementWithID elementID: UUID) -> FileSystemElement? {
        guard let elements = fileSystem.elements else { return nil }
        if elements.contains(where: { $0.id == elementID }) {
            return fileSystem
        }
        return getContainer(forElementID: elementID, in: elements)
    }

    private func getContainer(forElementID elementID: UUID,
                              in elements: [FileSystemElement]) -> FileSystemElement? {
        for element in elements {
            if let index = element.elements?.firstIndex(where: { $0.id == elementID }) {
                return element
            }
            guard let elements = element.elements else { continue }
            if let containerElement = getContainer(forElementID: elementID, in: elements) {
                return containerElement
            }
        }
        return nil
    }

    mutating func deleteFileSystemElement(by elementID: UUID) -> Bool {
        guard var updated = fileSystem.elements else { return false }
        let result = deleteFileSystemElement(by: elementID, in: &updated)
        fileSystem.elements = updated
        return result
    }

    private mutating func deleteFileSystemElement(by elementID: UUID,
                                                  in elements: inout [FileSystemElement]) -> Bool {
        if let index = elements.firstIndex(where: { $0.id == elementID }) {
            elements.remove(at: index)
            return true
        }
        for element in elements {
            guard let index = elements.firstIndex(where: { $0.id == element.id }) else { continue }
            if deleteFileSystemElement(by: elementID, in: &elements[index].elements!) {
                return true
            }
        }
        return false
    }

    mutating func moveFileSystemElement(withID elementID: UUID, toFolderWithID folderID: UUID) {
        guard let elementToMove = firstFileSystemElement(where: { $0.id == elementID }) else {
            return
        }
        _ = deleteFileSystemElement(by: elementToMove.id)
        addElement(elementToMove, toFolderWithID: folderID)
    }
}
