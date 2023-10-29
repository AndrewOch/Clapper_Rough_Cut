import SwiftUI

struct FileSystemElementView: View {
    @Binding var element: FileSystemElement

    var body: some View {
        HStack(alignment: .center) {
            HStack(spacing: 5) {
                FileIcon(type: element.type)
                    .frame(width: 10, height: 10)
                    .scaledToFit()
                CustomLabel<BodyMediumStyle>(text: element.title)
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
