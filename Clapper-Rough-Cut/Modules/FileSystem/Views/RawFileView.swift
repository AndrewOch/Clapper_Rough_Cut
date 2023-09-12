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
                    .foregroundColor(selected ? Asset.light.swiftUIColor : Asset.semiDark.swiftUIColor)
                Label<BodyMediumStyle>(text: file.url.lastPathComponent)
                    .foregroundColor(selected ? Asset.semiWhite.swiftUIColor : Asset.dark.swiftUIColor)
                    .lineLimit(1)
                Spacer()
                if file.transcription != nil {
                    TranscribedIcon()
                        .foregroundColor(selected ? Asset.light.swiftUIColor : Asset.dark.swiftUIColor)
                }
                HStack {
                    Label<BodyMediumStyle>(text: Formatter.formatDuration(duration: file.duration))
                        .foregroundColor(selected ? Asset.semiWhite.swiftUIColor : Asset.dark.swiftUIColor)
                    Spacer()
                }
                .frame(width: 60)
                HStack {
                    Label<BodyMediumStyle>(text: Formatter.formatDate(date: file.createdAt))
                        .foregroundColor(selected ? Asset.light.swiftUIColor : Asset.tertiary.swiftUIColor)
                    Spacer()
                }
                .frame(width: 200)
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 5)
            .background(selected ? Asset.accentPrimary.swiftUIColor : Asset.light.swiftUIColor)
            .cornerRadius(5)
        }
        .focusable(false)
        .buttonStyle(PlainButtonStyle())
    }
}
