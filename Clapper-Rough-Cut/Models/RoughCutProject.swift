import Foundation

struct RoughCutProject: Identifiable, Codable {
    var id = UUID()
    var scriptFile: ScriptFile?
    var unsortedFolder = RawFilesFolder()
    var phraseFolders: [RawFilesFolder] = []
    
    var selectedFile: RawFile?
    var selectedFolder: RawFilesFolder?
    var selectedTake: RawTake?
    
    var hasUntranscribedFiles: Bool = false
    var hasUnsortedTranscribedFiles: Bool = false
    var canSortScenes: Bool = false
    var hasUnmatchedSortedFiles: Bool = false
    
    var exportSettings: ExportSettings = ExportSettings()
}
