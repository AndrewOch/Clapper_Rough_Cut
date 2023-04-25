//
//  Clapper_Rough_CutDocument.swift
//  Clapper Rough-Cut
//
//  Created by andrewoch on 03.02.2023.
//

import SwiftUI
import UniformTypeIdentifiers
import Foundation

extension UTType {
    static var clapperPost: UTType {
        UTType(importedAs: "com.clapper.post")
    }
}

// MARK: - App Document
final class ClapperRoughCutDocument: ReferenceFileDocument {
    typealias Snapshot = RoughCutProject
    
    @Published var project: RoughCutProject
    let transcriber: AudioTranscriber = WhisperAudioTranscriber()
    let phraseMatcher: PhraseMatcherProtocol = PhraseMatcher()

    static var readableContentTypes: [UTType] { [.clapperPost] }

    func snapshot(contentType: UTType) throws -> RoughCutProject {
        project
    }
    
    init() {
        project = RoughCutProject()
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.project = try JSONDecoder().decode(RoughCutProject.self, from: data)
    }
    
    func fileWrapper(snapshot: RoughCutProject, configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(snapshot)
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        return fileWrapper
    }
}

// MARK: - Update Status
extension ClapperRoughCutDocument {
    func updateStatus() {
        project.hasUntranscribedFiles = project.unsortedFolder.files.filter({ file in file.transcription == nil }).count > 0
        project.hasUnsortedTranscribedFiles = project.unsortedFolder.files.filter({ file in file.transcription != nil }).count > 0
        project.canSortScenes = project.hasUnsortedTranscribedFiles && project.scriptFile != nil
        
        let files = project.phraseFolders.flatMap({ folder in folder.files })
        let videos = files.filter { file in file.type == .video }
        let audios = files.filter { file in file.type == .audio }
        project.hasUnmatchedSortedFiles = videos.count > 0 && audios.count > 0
    }
}
