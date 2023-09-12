import SwiftUI

public protocol ImageButtonStyle {
    static var cornerRadius: CGFloat { get }
    static var foregroundColor: SwiftUI.Color { get }
    static var backgroundColor: SwiftUI.Color { get }
    static var borderWidth: CGFloat { get }
    static var paddingHorizontal: CGFloat { get }
    static var paddingTop: CGFloat { get }
    static var paddingBottom: CGFloat { get }
    static var imageSize: CGFloat { get }
    static var borderColor: SwiftUI.Color { get }
}

public enum ImageButtonLogoStyle: ImageButtonStyle {
    public static var cornerRadius: CGFloat = 0
    public static var foregroundColor: SwiftUI.Color = Asset.white.swiftUIColor
    public static var backgroundColor: SwiftUI.Color = .clear
    public static var borderWidth: CGFloat = 0
    public static var paddingHorizontal: CGFloat = 0
    public static var paddingTop: CGFloat = 0
    public static var paddingBottom: CGFloat = 0
    public static var imageSize: CGFloat = 32
    public static var borderColor: SwiftUI.Color = .clear
}

struct ImageButton<Style: ImageButtonStyle>: View {
    var image: Image
    @Binding var enabled: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                image.resizable()
                    .scaledToFit()
                    .frame(width: Style.imageSize, height: Style.imageSize)
                    .foregroundColor(Style.foregroundColor)
            }
            .padding(.horizontal, Style.paddingHorizontal)
            .padding(.top, Style.paddingTop)
            .padding(.bottom, Style.paddingBottom)
            .background(Style.backgroundColor)
            .cornerRadius(Style.cornerRadius)
            .overlay(RoundedRectangle(cornerRadius: Style.cornerRadius)
                .stroke(Style.borderColor, lineWidth: Style.borderWidth))
        }
        .focusable(false)
        .buttonStyle(PlainButtonStyle())
        .disabled(!enabled)
    }
}
