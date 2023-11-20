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
    var subtitles: [Subtitle]?
    var mfccs: [[Float]]?
    var collapsed: Bool = false
    var syncResult: AudioSyncResult? = nil

    init(title: String,
         type: FileSystemElementType,
         createdAt: Date? = nil,
         statuses: [FileStatus] = [],
         duration: Double? = nil,
         containerId: UUID? = nil,
         scriptPhraseId: UUID? = nil,
         url: URL? = nil,
         transcription: [Subtitle]? = nil,
         mfccs: [[Float]]? = nil,
         collapsed: Bool = false,
         syncResult: AudioSyncResult? = nil) {
        self.title = title
        self.type = type
        self.createdAt = createdAt
        self.statuses = statuses
        self.duration = duration
        self.containerId = containerId
        self.scriptPhraseId = scriptPhraseId
        self.url = url
        self.subtitles = transcription
        self.mfccs = mfccs
        self.collapsed = collapsed
        self.syncResult = syncResult
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

extension FileSystemElement {
    var fullSubtitles: String? {
        guard let subtitles = subtitles else { return nil }
        return subtitles.map { $0.text }.joined(separator: " ")
    }

    func currentSubtitle(time: Double) -> Subtitle? {
        guard let subtitles = subtitles else { return nil }
        return subtitles.first { subtitle in
            subtitle.startTime >= time && time <= subtitle.endTime
        }
    }
}

enum FileSystemElementType: Int, Codable, Hashable {
    case audio = 0
    case video = 1
    case take = 2
    case scene = 3
    case folder = 4
}

extension FileSystemElementType {
    var stringValue: String {
        switch self {
        case .audio:
            return L10n.audio
        case .video:
            return L10n.video
        case .take:
            return L10n.take
        case .scene:
            return L10n.scene
        case .folder:
            return L10n.folder
        }
    }
}

enum FileStatus: Codable, Hashable {
    case transcribing
    case transcription
}

extension FileSystemElement {
    var scriptMatchingAccuracy: Double {
        guard let accuracy = subtitles?.compactMap({ $0.matchAccuracy }).max() else { return 0 }
        return accuracy
    }
}
