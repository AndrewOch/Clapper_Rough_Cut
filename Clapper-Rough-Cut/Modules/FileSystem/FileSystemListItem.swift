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
        if lhs.value.type.rawValue < rhs.value.type.rawValue {
            return true
        } else if lhs.value.type.rawValue > rhs.value.type.rawValue {
            return false
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
