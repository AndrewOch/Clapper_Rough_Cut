import SwiftUI

struct CustomTextField: View {
    @State var title: String
    @State var placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(spacing: 5) {
            HStack {
                CustomLabel<BodyMediumStyle>(text: title)
                    .foregroundColor(Asset.semiDark.swiftUIColor)
                Spacer()
            }.padding(.horizontal, 10)
            TextField(title, text: $text)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .focusable(false)
                .textFieldStyle(.plain)
                .foregroundColor(Asset.dark.swiftUIColor)
                .tint(Asset.accentPrimary.swiftUIColor)
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                .background {
                    if text.isEmpty {
                        HStack(alignment: .bottom) {
                            CustomLabel<BodyMediumStyle>(text: placeholder)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10)
                                .foregroundColor(Asset.secondary.swiftUIColor)
                            Spacer()
                        }.disabled(true)
                    }
                }
                .background(Asset.white.swiftUIColor)
                .cornerRadius(10)
                .font(.custom(BodyMediumStyle.fontName, size: BodyMediumStyle.fontSize))
                .overlay(
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Asset.tertiary.swiftUIColor, lineWidth: 1)
                            .background(.clear)
                    }
                )
        }
    }
}
