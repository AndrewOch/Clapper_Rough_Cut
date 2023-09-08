import SwiftUI

struct FileIcon: View {
    var type: RawFileType?

    var body: some View {
        Image(systemName: getFileImageName(type: type))
    }

    private func getFileImageName(type: RawFileType?) -> String {
        if let type = type {
            if type == .audio {
                return "mic"
            } else if type == .video {
                return "video.square"
            }
        }
        return "doc"
    }
}
