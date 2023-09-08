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
            .foregroundColor(.black)
            .tint(.purple)
            .padding(.vertical, 8)
            .padding(.horizontal, 5)
            .background(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray, lineWidth: 1)
            )
    }
}
