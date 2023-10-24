import Foundation

struct RoughCutProject: Identifiable, Codable {
    var id = UUID()
    var scriptFile: ScriptFile?
    var fileSystem: RoughCutFileSystem = RoughCutFileSystem()
    var exportSettings: ExportSettings = ExportSettings()
}

// MARK: - Project states
extension RoughCutProject {
    var hasUntranscribedFiles: Bool {
        return fileSystem.allElements(where: { $0.isFile && $0.subtitles == nil }).isNotEmpty
    }
    var hasUnsortedTranscribedFiles: Bool {
        return fileSystem.allElements(where: { $0.isFile && $0.subtitles != nil }).isNotEmpty
    }
    var canSortScenes: Bool {
        return hasUntranscribedFiles && scriptFile != nil
    }
    var hasUnmatchedSortedFiles: Bool {
        fileSystem.firstElement { scene in
            scene.isScene &&
            fileSystem.firstElement(where: { $0.containerId == scene.id && $0.type == .audio }) != nil &&
            fileSystem.firstElement(where: { $0.containerId == scene.id && $0.type == .video }) != nil
        } != nil
    }
}
