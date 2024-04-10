import SwiftUI

struct CustomSearchTextField: View {
    
    @State var title: String?
    @State var placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(spacing: 2) {
            if let title = title {
                HStack {
                    CustomLabel<BodySmallStyle>(text: title)
                        .foregroundColor(Asset.contentTertiary.swiftUIColor)
                    Spacer()
                }.padding(.horizontal, 5)
            }
            HStack {
                SystemImage.magnifyingglass.imageView
                    .frame(width: 14, height: 14)
                    .foregroundColor(Asset.contentPrimary.swiftUIColor)
                TextField(placeholder, text: $text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .focusable(false)
                    .textFieldStyle(.plain)
                    .tint(Asset.accentPrimary.swiftUIColor)
                    .font(.custom(BodySmallStyle.fontName, size: BodySmallStyle.fontSize))
                    .foregroundColor(Asset.contentPrimary.swiftUIColor)
                if text.isNotEmpty {
                    ImageButton<ImageButtonSystemStyle>(image: SystemImage.xmarkCircleFill.imageView,
                                enabled: .constant(true)) {
                        text = .empty
                    }
                    .frame(width: 14, height: 14)
                    .foregroundColor(Asset.contentTertiary.swiftUIColor)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            .background(Asset.surfaceSecondary.swiftUIColor)
            .cornerRadius(8)
            .overlay(
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Asset.surfaceTertiary.swiftUIColor, lineWidth: 1)
                        .background(.clear)
                }
            )
        }
    }
}
