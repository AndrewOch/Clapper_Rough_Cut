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
        let existingFiles: [FileSystemElement] = project.fileSystem.allElements(where: { $0.isFile })
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
            project.fileSystem.addElement(newFile)
        }
    }

    public func transcribeFile(_ file: FileSystemElement) {
        registerUndo()
        var transcribingFile = file
        transcribingFile.statuses.append(.transcribing)
        project.fileSystem.updateElement(withID: file.id, newValue: transcribingFile)
        transcriber.transcribeFile(file, quality: .high)
            .sink { [weak self] completedFile in
                guard let self = self else { return }
                guard var file = self.project.fileSystem.elementById(completedFile.id) else { return }
                file.statuses.removeAll(where: { $0 == .transcribing })
                file.statuses.append(.transcription)
                file.transcription = completedFile.transcription
                self.project.fileSystem.updateElement(withID: file.id, newValue: file)
            }
            .store(in: &cancellables)
    }

    public func transcribeFiles() {
        registerUndo()
        let filtered = project.fileSystem.allElements(where: { $0.isFile }).filter({ $0.transcription == nil })
        filtered.forEach({
            var transcribingFile = $0
            transcribingFile.statuses.append(.transcribing)
            project.fileSystem.updateElement(withID: $0.id, newValue: transcribingFile)
        })
        transcriber.transcribeFiles(filtered, quality: .high)
            .sink { [weak self] completedFile in
                guard let self = self else { return }
                guard var file = self.project.fileSystem.elementById(completedFile.id) else { return }
                file.statuses.removeAll(where: { $0 == .transcribing })
                file.statuses.append(.transcription)
                file.transcription = completedFile.transcription
                self.project.fileSystem.updateElement(withID: file.id, newValue: file)
            }
            .store(in: &cancellables)
    }
}
