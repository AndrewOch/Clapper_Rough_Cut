import SwiftUI

public protocol RoundedButtonStyle {
    static var fontName: String { get }
    static var fontSize: CGFloat { get }
    static var cornerRadius: CGFloat { get }
    static var foregroundColor: SwiftUI.Color { get }
    static var backgroundColor: SwiftUI.Color { get }
    static var elementsSpacing: CGFloat { get }
    static var borderWidth: CGFloat { get }
    static var paddingHorizontal: CGFloat { get }
    static var paddingVertical: CGFloat { get }
    static var imageSize: CGFloat { get }
    static var borderColor: SwiftUI.Color { get }
}

public enum RoundedButtonPrimaryMediumStyle: RoundedButtonStyle {
    public static var fontName: String = FontFamily.Overpass.regular.name
    public static var fontSize: CGFloat = 12
    public static var cornerRadius: CGFloat = 10
    public static var foregroundColor: SwiftUI.Color = .white
    public static var backgroundColor: SwiftUI.Color = Asset.accentPrimary.swiftUIColor
    public static var elementsSpacing: CGFloat = 8
    public static var borderWidth: CGFloat = 0
    public static var paddingHorizontal: CGFloat = 16
    public static var paddingVertical: CGFloat = 12
    public static var imageSize: CGFloat = 12
    public static var borderColor: SwiftUI.Color = .clear
}

struct RoundedButton<Style: RoundedButtonStyle>: View {
    var title: String
    var imageName: String?
    @Binding var enabled: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if let imageName = imageName {
                    Image(systemName: imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Style.imageSize, height: Style.imageSize)
                }
                Text(title)
                    .font(.custom(Style.fontName, size: Style.fontSize))
                    .lineLimit(1)
            }
            .foregroundColor(Style.foregroundColor)
            .padding(.horizontal, Style.paddingHorizontal)
            .padding(.vertical, Style.paddingVertical)
            .background(Style.backgroundColor)
            .cornerRadius(Style.cornerRadius)
            .border(Style.borderColor, width: Style.borderWidth)
        }
        .focusable(false)
        .buttonStyle(PlainButtonStyle())
        .disabled(!enabled)
    }
}
