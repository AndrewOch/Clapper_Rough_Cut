import Foundation

struct FileSystemElement: Identifiable, Equatable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String
    let type: FileSystemElementType
    var createdAt: Date?
    var statuses: [FileStatus]
    var duration: Double?
    var containerId: UUID?
    var scriptPhraseId: UUID?
    let url: URL?
    var transcription: String?
    var mfccs: [[Float]]?
    var collapsed: Bool = false

    init(title: String,
         type: FileSystemElementType,
         createdAt: Date? = nil,
         statuses: [FileStatus] = [],
         duration: Double? = nil,
         containerId: UUID? = nil,
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
        self.containerId = containerId
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

    var isContainer: Bool {
        return isFolder || isScene || isTake
    }
}

enum FileSystemElementType: Int, Codable, Hashable {
    case audio = 0
    case video = 1
    case take = 2
    case scene = 3
    case folder = 4
}

enum FileStatus: Codable, Hashable {
    case transcribing
    case transcription
}
