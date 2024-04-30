import Foundation

struct FileSystemListItem: Identifiable, Hashable {
    let id: UUID
    let value: FileSystemElement
    let elements: [FileSystemListItem]?
    var highlights: [FileSystemListItemHighlight] = []

    init(value: FileSystemElement, elements: [FileSystemListItem]?) {
        self.id = value.id
        self.value = value
        self.elements = elements
    }

    static func < (lhs: FileSystemListItem, rhs: FileSystemListItem) -> Bool {
        if lhs.value.isMatched && !rhs.value.isMatched {
            return true
        } else if !lhs.value.isMatched && rhs.value.isMatched {
            return false
        }

        if lhs.value.isMatched && rhs.value.isMatched {
            if lhs.value.matchingAccuracy != rhs.value.matchingAccuracy {
                return lhs.value.matchingAccuracy > rhs.value.matchingAccuracy
            }
        }

        if let lhsDate = lhs.value.createdAt, let rhsDate = rhs.value.createdAt {
            if lhsDate != rhsDate {
                return lhsDate > rhsDate
            }
        }

        if lhs.value.type.rawValue != rhs.value.type.rawValue {
            return lhs.value.type.rawValue < rhs.value.type.rawValue
        }

        return lhs.value.title < rhs.value.title
    }

}

enum FileSystemListItemHighlight {
    case type
    case title
    case subtitles
    case videoClasses
    case audioClasses
    case date
}
