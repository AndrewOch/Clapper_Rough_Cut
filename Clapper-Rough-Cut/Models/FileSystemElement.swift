import Foundation

struct FileSystemElement: Identifiable, Equatable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String
    let type: RawFileType
    var createdAt: Date?
    var statuses: [FileStatus]
    var duration: Double?
    var elements: [UUID:FileSystemElement]
    var scriptPhraseId: UUID?
    let url: URL?
    var transcription: String?
    var mfccs: [[Float]]?
    var collapsed: Bool = false

    init(title: String,
         type: RawFileType,
         createdAt: Date? = nil,
         statuses: [FileStatus] = [],
         duration: Double? = nil,
         elements: [UUID:FileSystemElement] = [:],
         scriptPhraseId: UUID? = nil,
         url: URL? = nil,
         transcription: String? = nil,
         mfccs: [[Float]]? = nil,
         collapsed: Bool = false) {
        self.title = title
        self.type = type
        self.createdAt = createdAt
        self.statuses = statuses
        self.duration = duration
        self.elements = elements
        self.scriptPhraseId = scriptPhraseId
        self.url = url
        self.transcription = transcription
        self.mfccs = mfccs
        self.collapsed = collapsed
    }

    static func == (lhs: FileSystemElement, rhs: FileSystemElement) -> Bool {
        lhs.id == rhs.id
    }
}

extension FileSystemElement {
    var isFile: Bool {
        return type == .audio || type == .video
    }

    var isFolder: Bool {
        return type == .folder
    }

    var isScene: Bool {
        return type == .scene
    }

    var isTake: Bool {
        return type == .take
    }
}

enum RawFileType: Codable, Hashable {
    case audio
    case video
    case folder
    case take
    case scene
}

enum FileStatus: Codable, Hashable {
    case transcribing
    case transcription
}
