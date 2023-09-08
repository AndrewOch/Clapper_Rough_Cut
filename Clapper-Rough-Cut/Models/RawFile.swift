import Foundation

class RawFilesFolder: Identifiable, Equatable, Codable {
    var id = UUID()
    var title: String
    var files: [RawFile]
    var takes: [RawTake]
    var scriptPhraseId: UUID?
    var collapsed: Bool = false

    // Init for unsorted (default) folder
    init() {
        self.title = L10n.unsorted.capitalized
        self.files = []
        self.scriptPhraseId = nil
        self.takes = []
    }

    // Init for phrase folder
    init(title: String, files: [RawFile] = [], takes: [RawTake] = [], scriptPhraseId: UUID? = nil) {
        self.title = title
        self.files = files
        self.scriptPhraseId = scriptPhraseId
        self.takes = takes
    }

    static func == (lhs: RawFilesFolder, rhs: RawFilesFolder) -> Bool {
        lhs.id == rhs.id
    }
}

class RawTake: Identifiable, Equatable, Codable {
    var id = UUID()
    var video: RawFile
    var audio: RawFile

    init(video: RawFile, audio: RawFile) {
        self.video = video
        self.audio = audio
    }

    static func == (lhs: RawTake, rhs: RawTake) -> Bool {
        lhs.id == rhs.id
    }
}

class RawFile: Identifiable, Equatable, Codable {
    var id = UUID()
    let url: URL
    let duration: Double
    let createdAt: Date
    let type: RawFileType
    var transcription: String?
    var mfccs: [[Float]]?

    init(url: URL, duration: Double, type: RawFileType, createdAt: Date) {
            self.url = url
            self.duration = duration
            self.type = type
            self.createdAt = createdAt
        }

    static func == (lhs: RawFile, rhs: RawFile) -> Bool {
            lhs.id == rhs.id
        }
}

enum RawFileType: Codable {
    case audio
    case video
}
