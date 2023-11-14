import SwiftUI

struct SubtitlesView: View {
    @Binding var subtitles: [Subtitle]

    var body: some View {
        let combinedText = subtitles.reduce(Text(String.empty)) { (combined, subtitle) -> Text in
            let subtitleColor = Asset.contentTertiary.swiftUIColor
                .interpolated(to: Asset.accentPrimary.swiftUIColor, fraction: subtitle.matchAccuracy ?? 0)
            let subtitleText = Text("\(subtitle.text) ")
                .foregroundColor(subtitleColor)
            return combined + subtitleText
        }
        return combinedText
    }
}
