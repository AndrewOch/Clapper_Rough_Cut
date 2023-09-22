import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct RawFileView: View {
    @State var file: FileSystemElement
    var action: () -> Void
    var selected: Bool

    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                if let url = file.url, let duration = file.duration, let createdAt = file.createdAt {
                    FileIcon(type: file.type)
                        .foregroundColor(selected ? Asset.light.swiftUIColor : Asset.semiDark.swiftUIColor)
                    CustomLabel<BodyMediumStyle>(text: url.lastPathComponent)
                        .foregroundColor(selected ? Asset.semiWhite.swiftUIColor : Asset.dark.swiftUIColor)
                        .lineLimit(1)
                    Spacer()
                    if file.transcription != nil {
                        TranscribedIcon()
                            .foregroundColor(selected ? Asset.light.swiftUIColor : Asset.dark.swiftUIColor)
                    }
                    HStack {
                        CustomLabel<BodyMediumStyle>(text: Formatter.formatDuration(duration: duration))
                            .foregroundColor(selected ? Asset.semiWhite.swiftUIColor : Asset.dark.swiftUIColor)
                        Spacer()
                    }
                    .frame(width: 60)
                    HStack {
                        CustomLabel<BodyMediumStyle>(text: Formatter.formatDate(date: createdAt))
                            .foregroundColor(selected ? Asset.light.swiftUIColor : Asset.tertiary.swiftUIColor)
                        Spacer()
                    }
                    .frame(width: 200)
                }
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(selected ? Asset.accentPrimary.swiftUIColor : Asset.light.swiftUIColor)
            .cornerRadius(5)
        }
        .focusable(false)
        .buttonStyle(PlainButtonStyle())
    }
}
