import Foundation
import AppKit
import SwiftUI
import UniformTypeIdentifiers
import AVFoundation

protocol FileSystemOperations {
    func addRawFiles()
    func transcribeSelectedFiles(_ selection: Set<FileSystemElement.ID>)
    func transcribeFile(_ file: FileSystemElement)
    func transcribeFiles(_ files: [FileSystemElement]?)
    func classifySelectedAudios(_ selection: Set<FileSystemElement.ID>)
    func classifyAudio(_ file: FileSystemElement)
    func classifyAudios(_ files: [FileSystemElement]?)
    func classifySelectedVideos(_ selection: Set<FileSystemElement.ID>)
    func classifyVideo(_ file: FileSystemElement)
    func classifyVideos(_ files: [FileSystemElement]?)
    func deleteSelectedFiles(_ selection: Set<FileSystemElement.ID>)
    func analizeFile(_ file: FileSystemElement)
    func analizeFiles(_ files: [FileSystemElement]?)
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
    
    public func analizeFile(_ file: FileSystemElement) {
        transcribeFile(file)
        classifyAudio(file)
        classifyVideo(file)
    }
    
    public func analizeFiles(_ files: [FileSystemElement]? = nil) {
        transcribeFiles(files)
        classifyAudios(files)
        classifyVideos(files)
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
                file.subtitles = completedFile.subtitles
                self.project.fileSystem.updateElement(withID: file.id, newValue: file)
            }
            .store(in: &cancellables)
    }

    public func transcribeFiles(_ files: [FileSystemElement]? = nil) {
        var filtered: [FileSystemElement] = []
        if let files = files {
            filtered = files.filter({ $0.isFile && $0.subtitles == nil })
        } else {
            filtered = project.fileSystem.allElements(where: { $0.isFile && $0.subtitles == nil })
        }
        guard !filtered.isEmpty else { return }
        registerUndo()
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
                file.subtitles = completedFile.subtitles
                self.project.fileSystem.updateElement(withID: file.id, newValue: file)
            }
            .store(in: &cancellables)
    }

    func transcribeSelectedFiles(_ selection: Set<FileSystemElement.ID>) {
        var files: [FileSystemElement] = []
        selection.forEach { uuid in
            guard let elem = project.fileSystem.elementById(uuid) else { return }
            files.append(elem)
        }
        transcribeFiles(files)
    }

    func classifyAudio(_ file: FileSystemElement) {
        registerUndo()
        var transcribingFile = file
        transcribingFile.statuses.append(.audioClassifying)
        project.fileSystem.updateElement(withID: file.id, newValue: transcribingFile)
        audioClassificator.classifyAudio(file: file) { elem in
            guard var element = self.project.fileSystem.elementById(elem.id) else { return }
            element.audioClasses = elem.audioClasses
            element.statuses.removeAll(where: { $0 == .audioClassifying })
            element.statuses.append(.audioClassification)
            self.project.fileSystem.updateElement(withID: file.id, newValue: element)
        }
    }

    func classifyAudios(_ files: [FileSystemElement]? = nil) {
        var filtered: [FileSystemElement] = []
        if let files = files {
            filtered = files.filter({ $0.isFile && $0.audioClasses == nil })
        } else {
            filtered = project.fileSystem.allElements(where: { $0.isFile && $0.audioClasses == nil })
        }
        guard !filtered.isEmpty else { return }
        registerUndo()
        filtered.forEach({
            var transcribingFile = $0
            transcribingFile.statuses.append(.audioClassifying)
            project.fileSystem.updateElement(withID: $0.id, newValue: transcribingFile)
        })
        audioClassificator.classifyAudios(files: filtered) { elements in
            elements.forEach { elem in
                guard var element = self.project.fileSystem.elementById(elem.id) else { return }
                element.audioClasses = elem.audioClasses
                element.statuses.removeAll(where: { $0 == .audioClassifying })
                element.statuses.append(.audioClassification)
                self.project.fileSystem.updateElement(withID: element.id, newValue: element)
            }
        }
    }

    func classifySelectedAudios(_ selection: Set<FileSystemElement.ID>) {
        var files: [FileSystemElement] = []
        selection.forEach { uuid in
            guard let elem = project.fileSystem.elementById(uuid) else { return }
            files.append(elem)
        }
        classifyAudios(files)
    }

    func classifyVideo(_ file: FileSystemElement) {
        registerUndo()
        var transcribingFile = file
        transcribingFile.statuses.append(.videoCaptioning)
        project.fileSystem.updateElement(withID: file.id, newValue: transcribingFile)
        videoCaptionizers.forEach { captionizer in
            captionizer.captionVideo(file: file) { classes in
                guard let classes = classes,
                      var element = self.project.fileSystem.elementById(file.id) else { return }
                var videoClasses: [ClassificationElement] = element.videoClasses ?? []
                videoClasses.append(contentsOf: classes)
                element.videoClasses = videoClasses
                element.statuses.removeAll(where: { $0 == .videoCaptioning })
                element.statuses.append(.videoCaption)
                self.project.fileSystem.updateElement(withID: file.id, newValue: element)
            }
        }
    }

    func classifyVideos(_ files: [FileSystemElement]? = nil) {
        var filtered: [FileSystemElement] = []
        if let files = files {
            filtered = files.filter({ $0.type == .video && $0.videoClasses == nil })
        } else {
            filtered = project.fileSystem.allElements(where: { $0.type == .video && $0.videoClasses == nil })
        }
        guard !filtered.isEmpty else { return }
        registerUndo()
        filtered.forEach({
            var transcribingFile = $0
            transcribingFile.statuses.append(.videoCaptioning)
            project.fileSystem.updateElement(withID: $0.id, newValue: transcribingFile)
        })
        videoCaptionizers.forEach { captionizer in
            captionizer.captionVideos(files: filtered) { results in
                results.forEach { id, classes in
                    guard let classes = classes,
                          var element = self.project.fileSystem.elementById(id) else { return }
                    var videoClasses: [ClassificationElement] = element.videoClasses ?? []
                    videoClasses.append(contentsOf: classes)
                    element.videoClasses = videoClasses
                    element.statuses.removeAll(where: { $0 == .videoCaptioning })
                    element.statuses.append(.videoCaption)
                    self.project.fileSystem.updateElement(withID: element.id, newValue: element)
                }
            }
        }
    }

    func classifySelectedVideos(_ selection: Set<FileSystemElement.ID>) {
        var files: [FileSystemElement] = []
        selection.forEach { uuid in
            guard let elem = project.fileSystem.elementById(uuid) else { return }
            files.append(elem)
        }
        classifyVideos(files)
    }

    func deleteSelectedFiles(_ selection: Set<FileSystemElement.ID>) {
        registerUndo()
        selection.forEach { _ = project.fileSystem.deleteElement(by: $0) }
    }
}
