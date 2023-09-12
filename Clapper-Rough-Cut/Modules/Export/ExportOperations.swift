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
        updateStatus()
    }

    func export() {
        let exportSettings = project.exportSettings
        let exportDirectory = URL(fileURLWithPath: exportSettings.path)
        let exportFolderURL = exportDirectory.appendingPathComponent(exportSettings.directoryName)
        createFolder(at: exportFolderURL)
        exportFolder(root: exportFolderURL, folder: project.unsortedFolder)
        project.phraseFolders.forEach { folder in
            exportFolder(root: exportFolderURL, folder: folder)
        }
    }

    private func exportFolder(root: URL, folder: RawFilesFolder) {
        let exportFolderURL = root.appendingPathComponent(folder.title)
        createFolder(at: exportFolderURL)
        folder.files.forEach { file in
            let fileName = file.url.lastPathComponent
            copyFile(from: file.url, to: exportFolderURL.appendingPathComponent(fileName))
        }
        var takes = folder.takes
        takes.sort { take1, take2 in
            min(take1.video.createdAt, take1.audio.createdAt) < min(take2.video.createdAt, take2.audio.createdAt)
        }
        var takeNum = 1
        takes.forEach { take in
            exportTake(root: exportFolderURL, take: take, num: takeNum)
            takeNum += 1
        }
    }

    private func exportTake(root: URL, take: RawTake, num: Int) {
        let exportFolderURL = root.appendingPathComponent("Take \(num)")
        createFolder(at: exportFolderURL)
        let videoName = take.video.url.lastPathComponent
        copyFile(from: take.video.url, to: exportFolderURL.appendingPathComponent(videoName))
        let audioName = take.audio.url.lastPathComponent
        copyFile(from: take.audio.url, to: exportFolderURL.appendingPathComponent(audioName))
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
