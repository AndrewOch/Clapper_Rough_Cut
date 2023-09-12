import SwiftUI

struct TextFieldComponent: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .focusable(false)
            .textFieldStyle(.plain)
            .foregroundColor(Asset.dark.swiftUIColor)
            .tint(Asset.accentPrimary.swiftUIColor)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(Asset.white.swiftUIColor)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Asset.tertiary.swiftUIColor, lineWidth: 1)
                    .background(.clear)
            )
    }
}
