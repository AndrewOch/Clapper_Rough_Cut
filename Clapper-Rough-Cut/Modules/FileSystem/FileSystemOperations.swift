import Foundation
import AppKit
import SwiftUI
import UniformTypeIdentifiers
import AVFoundation

protocol FileSystemOperations {
    func addRawFiles()
    func transcribeFile(_ file: FileSystemElement)
    func transcribeFiles()
}

// MARK: - File System Operations
extension ClapperRoughCutDocument: FileSystemOperations {

    public func addRawFiles() {
        registerUndo()
        let dialog = NSOpenPanel()
        dialog.title                   = "Choose multiple raw files"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = false
        dialog.allowsMultipleSelection = true
        dialog.allowedContentTypes     = [.audio, .movie]
        guard (dialog.runModal() == NSApplication.ModalResponse.OK) else { return }
        let existingFiles: [FileSystemElement] = project.findAllFileSystemElements(where: { $0.isFile })
        let results = dialog.urls
        let filtered = results.filter { res in
            !existingFiles.contains(where: { $0.url == res })
        }
        for url in filtered {
            var type: FileSystemElementType? = nil
            if let fileType = UTType(tag: url.pathExtension, tagClass: .filenameExtension, conformingTo: nil) {
                if fileType.isSubtype(of: .audio) {
                    type = .audio
                } else if fileType.isSubtype(of: .movie) {
                    type = .video
                }
            }
            guard let type = type else { continue }
            let audioAsset = AVURLAsset(url: url)
            let audioDuration = audioAsset.duration.seconds
            let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
            let createdAt = attributes?[.creationDate] as? Date ?? Date()
            let newFile = FileSystemElement(title: url.lastPathComponent,
                                            type: type,
                                            createdAt: createdAt,
                                            duration: audioDuration,
                                            url: url)
            project.addElement(newFile)
        }
    }

    public func transcribeFile(_ file: FileSystemElement) {
        registerUndo()
        transcriber.transcribeFile(file, quality: .high) { [weak self] newFile in
            guard let self = self else { return }
            self.project.updateFileSystemElement(withID: file.id, newValue: newFile)
        }
    }

    public func transcribeFiles() {
        registerUndo()
        let filtered = project.findAllFileSystemElements(where: { $0.isFile }).filter({ $0.transcription == nil })
        transcriber.transcribeFiles(filtered, quality: .high) { [weak self] newFile in
            guard let self = self else { return }
            self.project.updateFileSystemElement(withID: newFile.id, newValue: newFile)
        }
    }
}
