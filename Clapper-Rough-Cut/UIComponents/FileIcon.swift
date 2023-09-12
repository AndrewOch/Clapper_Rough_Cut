import SwiftUI

struct FileIcon: View {
    var type: RawFileType?

    var body: some View {
        Image(systemName: getFileImageName(type: type))
    }

    private func getFileImageName(type: RawFileType?) -> String {
        if let type = type {
            if type == .audio {
                return SystemImage.micFill.rawValue
            } else if type == .video {
                return SystemImage.videoSquareFill.rawValue
            }
        }
        return SystemImage.doc.rawValue
    }
}
