import SwiftUI
import UniformTypeIdentifiers
import Foundation
import Combine

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
    @Published var undoManager: UndoManager?
    let transcriber: AudioTranscriber = WhisperAudioTranscriber()
    let phraseMatcher: PhraseMatcherProtocol = PhraseMatcher()
    var headerMenuConfiguration: HeaderMenuConfiguration? = nil
    var cancellables = Set<AnyCancellable>()

    static var readableContentTypes: [UTType] { [.clapperPost] }

    func snapshot(contentType: UTType) throws -> RoughCutProject {
        project
    }

    init() {
        project = RoughCutProject()
        headerMenuConfiguration = HeaderMenuConfiguration(document: self)
        cleanFileSystemStatuses()
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.project = try JSONDecoder().decode(RoughCutProject.self, from: data)
        headerMenuConfiguration = HeaderMenuConfiguration(document: self)
        cleanFileSystemStatuses()
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
        let previousVersion = project
        registerUndo(oldValue: previousVersion)
    }

    private func registerUndo(oldValue: RoughCutProject) {
        undoManager?.registerUndo(withTarget: self) { target in
            let previousVersion = target.project
            target.registerUndo(oldValue: previousVersion)
            target.project = oldValue
        }
    }
}

// MARK: - Clean on init
extension ClapperRoughCutDocument {
    private func cleanFileSystemStatuses() {
        project.fileSystem.elements.forEach { element in
            var element = element
            if element.statuses.contains(.transcribing) {
                element.statuses.removeAll(where: { $0 == .transcribing })
                project.fileSystem.updateElement(withID: element.id, newValue: element)
            }
        }
    }
}
