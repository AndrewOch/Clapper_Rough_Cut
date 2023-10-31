import SwiftUI

struct CustomSearchTextField: View {
    @Environment(\.colorScheme) private var colorScheme
    @State var title: String?
    @State var placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(spacing: 2) {
            if let title = title {
                HStack {
                    CustomLabel<BodySmallStyle>(text: title)
                        .foregroundColor(Color.contentTertiary(colorScheme))
                    Spacer()
                }.padding(.horizontal, 5)
            }
            HStack {
                SystemImage.magnifyingglass.imageView
                    .frame(width: 14, height: 14)
                    .foregroundColor(Color.contentPrimary(colorScheme))
                TextField(placeholder, text: $text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .focusable(false)
                    .textFieldStyle(.plain)
                    .tint(Asset.accentPrimary.swiftUIColor)
                    .font(.custom(BodySmallStyle.fontName, size: BodySmallStyle.fontSize))
                    .foregroundColor(Color.contentPrimary(colorScheme))
                if text.isNotEmpty {
                    ImageButton<ImageButtonSystemStyle>(image: SystemImage.xmarkCircleFill.imageView,
                                enabled: .constant(true)) {
                        text = .empty
                    }
                    .frame(width: 14, height: 14)
                    .foregroundColor(Color.contentTertiary(colorScheme))
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            .background(Color.surfaceSecondary(colorScheme))
            .cornerRadius(8)
            .overlay(
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.surfaceTertiary(colorScheme), lineWidth: 1)
                        .background(.clear)
                }
            )
        }
    }
}
