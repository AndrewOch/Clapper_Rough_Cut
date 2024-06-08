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
    let videoCaptionizers: [VideoCaptionizerProtocol] = [ ActivityCaptionizer()]
    let audioClassificator: AudioClassificatorProtocol = AudioClassificator()
    let phraseMatcher: PhraseMatcherProtocol = PhraseMatcher()
    let actionMatcher: ActionMatcherProtocol = ActionMatcher()
    var headerMenuConfiguration: HeaderMenuConfiguration? = nil
    var cancellables = Set<AnyCancellable>()
    let mfccMatcher = MFCCService()

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
        project.syncToServer()
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
            if element.statuses.contains(.transcribing) || element.statuses.contains(.videoCaptioning) || element.statuses.contains(.audioClassifying) {
                element.statuses.removeAll(where: { $0 == .transcribing || $0 == .videoCaptioning || $0 == .audioClassifying })
                project.fileSystem.updateElement(withID: element.id, newValue: element)
            }
        }
    }
}
