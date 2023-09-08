import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct RawFileView: View {
    @State var file: RawFile
    var action: () -> Void
    var selected: Bool

    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                FileIcon(type: file.type)
                Text(file.url.lastPathComponent)
                    .lineLimit(1)
                Spacer()
                if file.transcription != nil {
                    TranscribedIcon()
                }
                Text(Formatter.formatDuration(duration: file.duration))
                Text(Formatter.formatDate(date: file.createdAt))
                    .foregroundColor(.secondary)
            }
        }
        .focusable(false)
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 5)
        .padding(.vertical, selected ? 5 : 1)
        .background(selected ? Color.purple.opacity(0.3) : Color.clear)
        .cornerRadius(5)
    }
}
