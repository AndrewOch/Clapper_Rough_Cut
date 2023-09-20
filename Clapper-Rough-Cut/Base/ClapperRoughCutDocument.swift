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
    @Published var states: DocumentStates = DocumentStates()
    let transcriber: AudioTranscriber = WhisperAudioTranscriber()
    let phraseMatcher: PhraseMatcherProtocol = PhraseMatcher()
    var headerMenuConfiguration: HeaderMenuConfiguration? = nil
    @Published var undoManager: UndoManager?

    static var readableContentTypes: [UTType] { [.clapperPost] }

    func snapshot(contentType: UTType) throws -> RoughCutProject {
        project
    }

    init() {
        project = RoughCutProject()
        headerMenuConfiguration = HeaderMenuConfiguration(document: self)
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.project = try JSONDecoder().decode(RoughCutProject.self, from: data)
        headerMenuConfiguration = HeaderMenuConfiguration(document: self)
    }

    func fileWrapper(snapshot: RoughCutProject, configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(snapshot)
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        return fileWrapper
    }
}

// MARK: - Undo/Redo
extension ClapperRoughCutDocument {
    func registerUndo() {
        let previousVersion = project.copy()
        registerUndo(from: project, to: previousVersion)
    }

    private func registerUndo(from oldValue: RoughCutProject, to newValue: RoughCutProject) {
        undoManager?.registerUndo(withTarget: self) { target in
            target.registerUndo(from: newValue, to: target.project)
            target.project = oldValue
        }
    }
}

// MARK: - Update Status
extension ClapperRoughCutDocument {
    func updateStatus() {
        project.hasUntranscribedFiles = project.unsortedFolder.files.filter({ file in file.transcription == nil }).isNotEmpty
        project.hasUnsortedTranscribedFiles = project.unsortedFolder.files.filter({ file in file.transcription != nil }).isNotEmpty
        project.canSortScenes = project.hasUnsortedTranscribedFiles && project.scriptFile != nil

        let files = project.phraseFolders.flatMap({ folder in folder.files })
        let videos = files.filter { file in file.type == .video }
        let audios = files.filter { file in file.type == .audio }
        project.hasUnmatchedSortedFiles = videos.isNotEmpty && audios.isNotEmpty
    }
}
