import SwiftUI

struct FileSystemListItemView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var item: FileSystemListItem

    var body: some View {
        let element = item.value
        let highlights = item.highlights
        HStack(alignment: .center) {
            HStack(spacing: 5) {
                FileIcon(type: element.type)
                    .frame(width: 10, height: 10)
                    .scaledToFit()
                    .foregroundStyle(highlights.contains(.type) ? Color.yellow : Color.contentSecondary(colorScheme))
                CustomLabel<BodyMediumStyle>(text: element.title)
                    .foregroundStyle(highlights.contains(.title) ? Color.yellow : Color.contentSecondary(colorScheme))
            }
            Spacer()
            HStack {
                if element.statuses.contains(.transcribing) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.5)
                        .frame(width: 10, height: 10)
                }
                if element.statuses.contains(.transcription) {
                    TranscribedIcon()
                        .foregroundStyle(highlights.contains(.subtitles) ? Color.yellow : Color.contentSecondary(colorScheme))
                }
            }
            .frame(width: 60)
            HStack {
                if let duration = element.duration {
                    CustomLabel<BodyMediumStyle>(text: Formatter.formatDuration(duration: duration))
                        .lineLimit(1)
                } else {
                    CustomLabel<BodyMediumStyle>(text: .nilParameter)
                        .lineLimit(1)
                }
                Spacer()
            }
            .frame(width: 60)
            HStack {
                if let date = element.createdAt {
                    CustomLabel<BodyMediumStyle>(text: Formatter.formatDate(date: date))
                        .lineLimit(1)
                } else {
                    CustomLabel<BodyMediumStyle>(text: .nilParameter)
                        .lineLimit(1)
                }
                Spacer()
            }
            .frame(width: 200)
        }
        .padding(.horizontal)
    }
}
