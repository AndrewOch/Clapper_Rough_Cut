struct FileSystemListItem: Identifiable, Hashable {
    let id: UUID
    let value: FileSystemElement
    let elements: [FileSystemListItem]?

    init(value: FileSystemElement, elements: [FileSystemListItem]?) {
        self.id = value.id
        self.value = value
        self.elements = elements
    }
}
