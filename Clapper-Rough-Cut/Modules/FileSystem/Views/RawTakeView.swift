import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct RawTakeView: View {
    @State var video: FileSystemElement
    @State var audio: FileSystemElement

    var action: () -> Void
    var selected: Bool

    var body: some View {
        Button {
            action()
        } label: {
            VStack {
                HStack {
                    if let url = video.url, let duration = video.duration, let createdAt = video.createdAt {
                        FileIcon(type: video.type)
                        CustomLabel<BodyMediumStyle>(text: url.lastPathComponent)
                            .lineLimit(1)
                        Spacer()
                        if video.transcription != nil {
                            TranscribedIcon()
                        }
                        CustomLabel<BodyMediumStyle>(text: Formatter.formatDuration(duration: duration))
                        CustomLabel<BodyMediumStyle>(text: Formatter.formatDate(date: createdAt))
                            .foregroundColor(Asset.secondary.swiftUIColor)
                    }
                }
                .padding(.bottom, 2)
                HStack {
                    if let url = audio.url, let duration = audio.duration, let createdAt = audio.createdAt {
                        
                        FileIcon(type: audio.type)
                        CustomLabel<BodyMediumStyle>(text: url.lastPathComponent)
                            .lineLimit(1)
                        Spacer()
                        if audio.transcription != nil {
                            TranscribedIcon()
                        }
                        CustomLabel<BodyMediumStyle>(text: Formatter.formatDuration(duration: duration))
                        CustomLabel<BodyMediumStyle>(text: Formatter.formatDate(date: createdAt))
                            .foregroundColor(Asset.secondary.swiftUIColor)
                    }
                }
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .cornerRadius(5)
        }
        .focusable(false)
        .buttonStyle(PlainButtonStyle())
        .background(selected ? Asset.accentPrimary.swiftUIColor : Asset.tertiary.swiftUIColor)
        .cornerRadius(5)
    }
}
