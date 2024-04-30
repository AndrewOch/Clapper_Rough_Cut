import SwiftUI

struct SubtitlesView: View {
    @Binding var subtitles: [Subtitle]

    var body: some View {
        let combinedText = subtitles.reduce(Text(String.empty)) { (combined, subtitle) -> Text in
            let subtitleColor = Asset.contentTertiary.swiftUIColor
                .interpolated(to: Asset.accentPrimary.swiftUIColor, fraction: subtitle.matchAccuracy ?? 0)
            let subtitleText = Text("\(subtitle.text) ")
                .fontWeight(subtitle.matchAccuracy ?? 0 > 0 ? .black : .regular)
                .foregroundColor(subtitle.matchAccuracy ?? 0 > 0 ? subtitleColor : Asset.surfaceTertiary.swiftUIColor )
            return combined + subtitleText
        }
        return combinedText
    }
}
