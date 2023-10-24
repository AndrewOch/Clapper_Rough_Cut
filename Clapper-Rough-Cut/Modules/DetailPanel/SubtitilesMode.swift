enum SubtitlesMode: Int {
    case full = 0
    case current = 1

    static var images: [SystemImage] {
        var images: [SystemImage] = []
        images.append(SystemImage.textJustify)
        images.append(SystemImage.timelineSelection)
        return images
    }
}
