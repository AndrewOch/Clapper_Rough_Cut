struct FileSystemListItem: Identifiable, Hashable {
    let id: UUID
    let value: FileSystemElement
    let elements: [FileSystemElement]

    init(value: FileSystemElement, nestingLevel: CGFloat, elements: [FileSystemElement]) {
        self.id = value.id
        self.value = value
        self.elements = elements
    }
}
