import SwiftUI

struct PrimaryButton: View {
    
    var title: String
    var imageName: String?
    var accesibilityIdentifier: String
    @Binding var enabled: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            PrimaryButtonLabel(title: title, imageName: imageName, enabled: enabled)
        }.accessibilityIdentifier(accesibilityIdentifier)
        .focusable(false)
        .buttonStyle(PlainButtonStyle())
        .disabled(!enabled)
    }
}

struct PrimaryButtonLabel: View {
    var title: String
    var imageName: String?
    var enabled: Bool

    var body: some View {
        HStack {
            if let imageName = imageName {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            }
            Text(title)
                .font(.caption)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            .purple
        )
        .cornerRadius(5)
    }
}
