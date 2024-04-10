import SwiftUI

struct CustomTextField: View {
    
    @State var title: String?
    @State var placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(spacing: 5) {
            if let title = title {
                HStack {
                    CustomLabel<BodyMediumStyle>(text: title)
                        .foregroundColor(Asset.contentSecondary.swiftUIColor)
                    Spacer()
                }.padding(.horizontal, 10)
            }
            TextField(placeholder, text: $text)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .focusable(false)
                .textFieldStyle(.plain)
                .foregroundColor(Asset.contentPrimary.swiftUIColor)
                .tint(Asset.accentPrimary.swiftUIColor)
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                .background(Asset.surfacePrimary.swiftUIColor)
                .cornerRadius(10)
                .font(.custom(BodyMediumStyle.fontName, size: BodyMediumStyle.fontSize))
                .overlay(
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Asset.contentTertiary.swiftUIColor, lineWidth: 1)
                            .background(.clear)
                    }
                )
        }
    }
}
