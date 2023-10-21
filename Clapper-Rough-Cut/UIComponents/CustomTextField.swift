import SwiftUI

struct CustomTextField: View {
    @Environment(\.colorScheme) private var colorScheme
    @State var title: String
    @State var placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(spacing: 5) {
            HStack {
                CustomLabel<BodyMediumStyle>(text: title)
                    .foregroundColor(Color.contentSecondary(colorScheme))
                Spacer()
            }.padding(.horizontal, 10)
            TextField(placeholder, text: $text)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .focusable(false)
                .textFieldStyle(.plain)
                .foregroundColor(Color.contentPrimary(colorScheme))
                .tint(Asset.accentPrimary.swiftUIColor)
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                .background(Color.surfacePrimary(colorScheme))
                .cornerRadius(10)
                .font(.custom(BodyMediumStyle.fontName, size: BodyMediumStyle.fontSize))
                .overlay(
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.contentTertiary(colorScheme), lineWidth: 1)
                            .background(.clear)
                    }
                )
        }
    }
}
