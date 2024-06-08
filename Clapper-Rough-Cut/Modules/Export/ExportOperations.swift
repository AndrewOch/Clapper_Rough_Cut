import Foundation
import AppKit

protocol ExportOperations {
    func selectExportFolder()
    func export()
}

extension ClapperRoughCutDocument: ExportOperations {
    func selectExportFolder() {
        let dialog = NSOpenPanel()
        dialog.title                   = "Choose script file"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = true
        dialog.allowsMultipleSelection = false
        dialog.allowedContentTypes     = [.directory]

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            if let result = dialog.url {
                project.exportSettings.path = result.path
            }
        }
    }

    func export() {
        let exportSettings = project.exportSettings
        let exportDirectory = URL(fileURLWithPath: exportSettings.path)
        let exportFolderURL = exportDirectory.appendingPathComponent(exportSettings.directoryName)
        exportFolder(root: exportFolderURL, folder: project.fileSystem.root)
    }
    
    private func exportFolder(root: URL, folder: FileSystemElement) {
        let exportFolderURL = root.appendingPathComponent(folder.title)
        createFolder(at: exportFolderURL)
        let containedElements = project.fileSystem.allElements(where: { $0.containerId == folder.id })
        
        containedElements.filter({ $0.isFile }).forEach { file in
            guard let url = file.url else { return }
            let fileName = url.lastPathComponent
            copyFile(from: url, to: exportFolderURL.appendingPathComponent(fileName))
        }
//        containedElements.filter({ $0.isScene }).forEach { file in
//            exportScene()
//        }
        containedElements.filter({ $0.isFolder }).forEach { file in
            exportFolder(root: exportFolderURL, folder: file)
        }
    }

    private func compareByMinCreatedAt(_ element1: FileSystemElement, _ element2: FileSystemElement) -> Bool {
        if let createdAt1 = element1.createdAt, let createdAt2 = element2.createdAt {
            return createdAt1 < createdAt2
        }
        return false
    }

    private func exportTake(root: URL, take: FileSystemElement, num: Int) {
        let exportFolderURL = root.appendingPathComponent("Take \(num)")
        createFolder(at: exportFolderURL)
        project.fileSystem.allElements(where: { $0.isFile && $0.containerId == take.id }).forEach { file in
            guard let url = file.url else { return }
            let name = url.lastPathComponent
            copyFile(from: url, to: exportFolderURL.appendingPathComponent(name))
        }
    }

    private func createFolder(at url: URL) {
        let fileManager = FileManager.default
        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            print("Folder created successfully")
        } catch {
            print("Error creating folder: \(error.localizedDescription)")
        }
    }

    private func copyFile(from sourceURL: URL, to destinationURL: URL) {
        let fileManager = FileManager.default
        do {
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            print("File copied successfully")
        } catch {
            print("Error copying file: \(error.localizedDescription)")
        }
    }
}

