import SwiftUI

struct FileIcon: View {
    var type: FileSystemElementType

    var body: some View {
        Image(systemName: getFileImageName(type: type))
    }

    private func getFileImageName(type: FileSystemElementType) -> String {
        switch type {
        case .audio:
            return SystemImage.micFill.rawValue
        case .video:
            return SystemImage.videoFill.rawValue
        case .folder:
            return SystemImage.folder.rawValue
        case .scene:
            return SystemImage.film.rawValue
        case .take:
            return SystemImage.filmStack.rawValue
        }
    }
}
