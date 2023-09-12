import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct RawTakeView: View {
    @State var video: RawFile
    @State var audio: RawFile

    var action: () -> Void
    var selected: Bool

    var body: some View {
        Button {
            action()
        } label: {
            VStack {
                HStack {
                    FileIcon(type: video.type)
                    Label<BodyMediumStyle>(text: video.url.lastPathComponent)
                        .lineLimit(1)
                    Spacer()
                    if video.transcription != nil {
                        TranscribedIcon()
                    }
                    Label<BodyMediumStyle>(text: Formatter.formatDuration(duration: video.duration))
                    Label<BodyMediumStyle>(text: Formatter.formatDate(date: video.createdAt))
                        .foregroundColor(Asset.secondary.swiftUIColor)
                }
                .padding(.bottom, 2)
                HStack {
                    FileIcon(type: audio.type)
                    Label<BodyMediumStyle>(text: audio.url.lastPathComponent)
                        .lineLimit(1)
                    Spacer()
                    if audio.transcription != nil {
                        TranscribedIcon()
                    }
                    Label<BodyMediumStyle>(text: Formatter.formatDuration(duration: audio.duration))
                    Label<BodyMediumStyle>(text: Formatter.formatDate(date: audio.createdAt))
                        .foregroundColor(Asset.secondary.swiftUIColor)
                }
            }
            .padding(.horizontal, 5)
            .padding(.vertical, selected ? 5 : 2)
            .cornerRadius(5)
        }
        .focusable(false)
        .buttonStyle(PlainButtonStyle())
        .background(selected ? Asset.accentPrimary.swiftUIColor : Asset.tertiary.swiftUIColor)
        .cornerRadius(5)
    }
}
