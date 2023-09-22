import Foundation

struct RoughCutProject: Identifiable, Codable {
    var id = UUID()
    var scriptFile: ScriptFile?
    var fileSystem: FileSystemElement = FileSystemElement(title: .empty, type: .folder)
    var exportSettings: ExportSettings = ExportSettings()
}

//MARK: - Project states
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
        findAllFileSystemElements(where: { $0.isScene &&
            $0.elements.values.contains(where: { $0.type == .audio}) &&
            $0.elements.values.contains(where: { $0.type == .video}) }).isNotEmpty
    }
}

//MARK: - FileSystem Utilities
extension RoughCutProject {
    func firstFileSystemElement(where predicate: (FileSystemElement) -> Bool,
                                excludeScenes: Bool = false,
                                excludeTakes: Bool = false,
                                recursiveSearch: Bool = true) -> FileSystemElement? {
        for (_, folder) in fileSystem.elements {
            if let result = firstFileSystemElement(from: folder,
                                                   where: predicate,
                                                   excludeScenes: excludeScenes,
                                                   excludeTakes: excludeTakes,
                                                   recursiveSearch: recursiveSearch) {
                return result
            }
            
        }
        return nil
    }
    
    private func firstFileSystemElement(from folder: FileSystemElement,
                                        where predicate: (FileSystemElement) -> Bool,
                                        excludeScenes: Bool = false,
                                        excludeTakes: Bool = false,
                                        recursiveSearch: Bool = true) -> FileSystemElement? {
        if let element = folder.elements.values.first(where: predicate) {
            return element
        }
        var result: FileSystemElement? = nil
        for element in folder.elements.values {
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
        var files: [FileSystemElement] = []
        
        for (_, folder) in fileSystem.elements {
            files.append(contentsOf: findAllFileSystemElements(from: folder,
                                                               where: predicate,
                                                               excludeScenes: excludeScenes,
                                                               excludeTakes: excludeTakes,
                                                               recursiveSearch: recursiveSearch))
        }
        return files
    }

    private func findAllFileSystemElements(from folder: FileSystemElement,
                             where predicate: (FileSystemElement) -> Bool,
                             excludeScenes: Bool = false,
                             excludeTakes: Bool = false,
                             recursiveSearch: Bool = true) -> [FileSystemElement] {
        var files: [FileSystemElement] = folder.elements.values.filter(predicate)
        folder.elements.values.forEach { element in
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
    
    mutating func addElement(_ newElement: FileSystemElement, toFolderWithID folderID: UUID) {
        guard var targetFolder = firstFileSystemElement(where: {$0.id == folderID }) else {
            return
        }
        targetFolder.elements[newElement.id] = newElement
        updateFileSystemElement(withID: targetFolder.id, newValue: targetFolder)
    }

    mutating func updateFileSystemElement(withID elementID: UUID,
                                          newValue: FileSystemElement) {
        updateFileSystemElement(withID: elementID, newValue: newValue, in: &fileSystem.elements)
    }

    private func updateFileSystemElement(withID elementID: UUID,
                                         newValue: FileSystemElement,
                                         in elements: inout [UUID: FileSystemElement]) {
        if let element = elements[elementID] {
            elements[elementID] = newValue
            return
        }
        for (key, element) in elements {
            if element.elements.isNotEmpty {
                updateFileSystemElement(withID: elementID, newValue: newValue, in: &elements[key]!.elements)
            }
        }
    }

    func getContainer(forElementWithID elementID: UUID) -> FileSystemElement? {
        return getContainer(forElementID: elementID, in: fileSystem.elements)
    }

    private func getContainer(forElementID elementID: UUID, in elements: [UUID: FileSystemElement]) -> FileSystemElement? {
        for (_, element) in elements {
            if element.elements[elementID] != nil {
                return element
            }
            if let containerElement = getContainer(forElementID: elementID, in: element.elements) {
                return containerElement
            }
        }
        return nil
    }

    mutating func deleteFileSystemElement(by elementID: UUID) -> Bool {
        var updated = fileSystem.elements
        let result = deleteFileSystemElement(by: elementID, in: &updated)
        fileSystem.elements = updated
        return result
    }

    private mutating func deleteFileSystemElement(by elementID: UUID, in elements: inout [UUID: FileSystemElement]) -> Bool {
        if elements[elementID] != nil {
            elements.removeValue(forKey: elementID)
            return true
        }
        for (key, _) in elements {
            if deleteFileSystemElement(by: elementID, in: &elements[key]!.elements) {
                return true
            }
        }
        return false
    }

    mutating func moveFileSystemElement(withID elementID: UUID, toFolderWithID folderID: UUID) {
        guard let elementToMove = firstFileSystemElement(where: { $0.id == elementID }) else {
            return
        }
        guard var targetFolder = firstFileSystemElement(where: { $0.id == folderID }) else {
            return
        }
        _ = deleteFileSystemElement(by: elementToMove.id)
        targetFolder.elements[elementToMove.id] = elementToMove
    }
}
