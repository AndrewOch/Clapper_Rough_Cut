//
//  ProjectEditViewModel.swift
//  Clapper Rough-Cut
//
//  Created by andrewoch on 03.02.2023.
//

import Foundation
import AppKit
import SwiftUI
import UniformTypeIdentifiers
import AVFoundation

protocol FileSystemOperations {
    func addRawFiles()
    func transcribeFile(_ file: RawFile)
    func transcribeFiles()
    func selectFile(_ file: RawFile)
    func selectFolder(_ folder: RawFilesFolder)
    func selectTake(_ take: RawTake)
}

// MARK: - File System Operations
extension ClapperRoughCutDocument: FileSystemOperations {
    
    public func addRawFiles() {
        let dialog = NSOpenPanel();
        dialog.title                   = "Choose multiple raw files";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = false;
        dialog.allowsMultipleSelection = true;
        dialog.allowedContentTypes     = [.audio, .movie];
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            var existingFiles: [RawFile] = []
            existingFiles += project.unsortedFolder.files
            existingFiles += project.phraseFolders.flatMap({ folder in folder.files })
            let results = dialog.urls
            let filtered = results.filter { res in
                !existingFiles.contains(where: { $0.url == res })
            }
            for url in filtered {
                var type: RawFileType? = nil
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
                project.unsortedFolder.files.append(RawFile(url: url, duration: audioDuration, type: type, createdAt: createdAt))
            }
            updateStatus()
        } else {
            return
        }
    }
    
    public func transcribeFile(_ file: RawFile) {
        transcriber.transcribeFile(file) { transcription in
            if let index = self.project.unsortedFolder.files.firstIndex(where: { $0.id == file.id }) {
                self.project.unsortedFolder.files[index].transcription = transcription
                self.updateStatus()
                return
            }
            for folder in self.project.phraseFolders {
                if let index = folder.files.firstIndex(where: { $0.id == file.id }) {
                    folder.files[index].transcription = transcription
                    self.updateStatus()
                    return
                }
            }
        }
    }
    
    public func transcribeFiles() {
        let filtered = project.unsortedFolder.files.filter { file in file.transcription == nil }
        transcriber.transcribeFiles(filtered) { url, transcription in
            if let index = self.project.unsortedFolder.files.firstIndex(where: { $0.url == url }) {
                self.project.unsortedFolder.files[index].transcription = transcription
            }
        }
        updateStatus()
    }
    
    public func getPhraseFolderForFile(_ file: RawFile?) -> RawFilesFolder? {
        guard let file = file else { return nil }
        var folder: RawFilesFolder? = nil
        project.phraseFolders.forEach { f in
            if f.files.contains(file) { folder = f }
        }
        return folder
    }
    
    func selectFile(_ file: RawFile) {
        project.selectedFile = file
        project.selectedFolder = nil
        project.selectedTake = nil
    }
    
    func selectFolder(_ folder: RawFilesFolder) {
        project.selectedFile = nil
        project.selectedFolder = folder
        project.selectedTake = nil
    }
    
    func selectTake(_ take: RawTake) {
        project.selectedFile = nil
        project.selectedFolder = nil
        project.selectedTake = take
    }
}
