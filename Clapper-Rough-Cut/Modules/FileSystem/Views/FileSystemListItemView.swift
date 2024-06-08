import SwiftUI

struct FileSystemListItemView: View {
    @Binding var item: FileSystemListItem

    var body: some View {
        let element = item.value
        let highlights = item.highlights
        HStack(alignment: .center) {
            HStack(spacing: 10) {
                if (element.isMatched) {
                    HStack {
                        Text(String("\(Int(element.matchingAccuracy * 100))%"))
                            .lineLimit(1)
                            .foregroundColor(Asset.contentPrimary.swiftUIColor)
                    }
                    .padding(5)
                    .background(Asset.surfacePrimary.swiftUIColor)
                    .cornerRadius(5)
                }
                FileIcon(type: element.type)
                    .frame(width: 10, height: 10)
                    .scaledToFit()
                    .foregroundStyle(highlights.contains(.type) ? Color.yellow : Asset.contentSecondary.swiftUIColor)
                CustomLabel<BodyMediumStyle>(text: element.title)
                    .foregroundStyle(highlights.contains(.title) ? Color.yellow : Asset.contentSecondary.swiftUIColor)
            }
            Spacer()
            statuses
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
                    CustomLabel<BodyMediumStyle>(text: Formatter.formatDateShort(date: date))
                        .lineLimit(1)
                } else {
                    CustomLabel<BodyMediumStyle>(text: .nilParameter)
                        .lineLimit(1)
                }
                Spacer()
            }
            .frame(width: 130)
        }
        .padding(.horizontal)
    }

    private var statuses: some View {
        let element = item.value
        let highlights = item.highlights
        var color: Color = .red
        if let marker = element.marker {
            switch marker {
            case .red:
                color = .red
            case .green:
                color = .green
            case .yellow:
                color = .yellow
            case .blue:
                color = .blue
            case .purple:
                color = .purple
            }
        }
        return HStack {
            Spacer()
            if (element.marker != nil) {
                SystemImage.circleFill.imageView
                    .resizable()
                    .frame(width: 10, height: 10)
                    .scaledToFit()
                    .foregroundColor(color)
            }
            if element.statuses.contains(.transcribing) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(0.5)
                    .frame(width: 10, height: 10)
            }
            if element.statuses.contains(.transcription) {
                TranscribedIcon()
                    .foregroundStyle(highlights.contains(.subtitles) ? Color.yellow : Asset.contentSecondary.swiftUIColor)
            }
            if element.statuses.contains(.audioClassifying) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(0.5)
                    .frame(width: 10, height: 10)
            }
            if element.statuses.contains(.audioClassification) {
                AudioClassificationIcon()
                    .foregroundStyle(highlights.contains(.audioClasses) ? Color.yellow : Asset.contentSecondary.swiftUIColor)
            }
            if element.statuses.contains(.videoCaptioning) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(0.5)
                    .frame(width: 10, height: 10)
            }
            if element.statuses.contains(.videoCaption) {
                VideoClassificationIcon()
                    .foregroundStyle(highlights.contains(.videoClasses) ? Color.yellow : Asset.contentSecondary.swiftUIColor)
            }
        }
        .frame(width: 60)
        .padding(.horizontal)
    }
}
