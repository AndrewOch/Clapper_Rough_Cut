struct FileSystemListItem: Identifiable, Hashable {
    let id: UUID
    let value: FileSystemElement
    let elements: [FileSystemListItem]?

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
