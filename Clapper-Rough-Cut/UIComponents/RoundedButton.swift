import SwiftUI

public protocol RoundedButtonStyle {
    static var fontName: String { get }
    static var fontSize: CGFloat { get }
    static var cornerRadius: CGFloat { get }
    static var foregroundColor: SwiftUI.Color { get }
    static var hoveredForegroundColor: SwiftUI.Color { get }
    static var selectedColor: SwiftUI.Color { get }
    static var backgroundColor: SwiftUI.Color { get }
    static var hoveredBackgroundColor: SwiftUI.Color { get }
    static var elementsSpacing: CGFloat { get }
    static var borderWidth: CGFloat { get }
    static var paddingHorizontal: CGFloat { get }
    static var paddingVertical: CGFloat { get }
    static var imageSize: CGFloat { get }
    static var baselineOffset: CGFloat { get }
    static var borderColor: SwiftUI.Color { get }
}

public enum RoundedButtonPrimaryMediumStyle: RoundedButtonStyle {
    public static var fontName: String = FontFamily.Overpass.regular.name
    public static var fontSize: CGFloat = 12
    public static var cornerRadius: CGFloat = 10
    public static var foregroundColor: SwiftUI.Color = Asset.white.swiftUIColor
    public static var selectedColor: SwiftUI.Color = Asset.accentDark.swiftUIColor
    public static var backgroundColor: SwiftUI.Color = Asset.accentPrimary.swiftUIColor
    public static var elementsSpacing: CGFloat = 8
    public static var borderWidth: CGFloat = 0
    public static var paddingHorizontal: CGFloat = 16
    public static var paddingVertical: CGFloat = 10
    public static var imageSize: CGFloat = 12
    public static var borderColor: SwiftUI.Color = .clear
    public static var hoveredForegroundColor: Color = Asset.white.swiftUIColor
    public static var hoveredBackgroundColor: Color = Asset.accentDark.swiftUIColor
    public static var baselineOffset: CGFloat = -2
}

public enum RoundedButtonSecondaryMediumStyle: RoundedButtonStyle {
    public static var fontName: String = FontFamily.Overpass.regular.name
    public static var fontSize: CGFloat = 12
    public static var cornerRadius: CGFloat = 10
    public static var foregroundColor: SwiftUI.Color = Asset.accentPrimary.swiftUIColor
    public static var selectedColor: SwiftUI.Color = Asset.accentDark.swiftUIColor
    public static var backgroundColor: SwiftUI.Color = Asset.white.swiftUIColor
    public static var elementsSpacing: CGFloat = 8
    public static var borderWidth: CGFloat = 1
    public static var paddingHorizontal: CGFloat = 16
    public static var paddingVertical: CGFloat = 10
    public static var imageSize: CGFloat = 12
    public static var borderColor: SwiftUI.Color = Asset.accentPrimary.swiftUIColor
    public static var hoveredForegroundColor: Color = Asset.white.swiftUIColor
    public static var hoveredBackgroundColor: Color = Asset.accentPrimary.swiftUIColor
    public static var baselineOffset: CGFloat = -2
}

public enum RoundedButtonHeaderMenuStyle: RoundedButtonStyle {
    public static var fontName: String = FontFamily.NunitoSans.bold.name
    public static var fontSize: CGFloat = 16
    public static var cornerRadius: CGFloat = 0
    public static var foregroundColor: SwiftUI.Color = Asset.white.swiftUIColor
    public static var selectedColor: SwiftUI.Color = Asset.accentDark.swiftUIColor
    public static var backgroundColor: SwiftUI.Color = .clear
    public static var elementsSpacing: CGFloat = 0
    public static var borderWidth: CGFloat = 0
    public static var paddingHorizontal: CGFloat = 8
    public static var paddingVertical: CGFloat = 15
    public static var imageSize: CGFloat = 12
    public static var borderColor: SwiftUI.Color = .clear
    public static var hoveredForegroundColor: Color = Asset.white.swiftUIColor
    public static var hoveredBackgroundColor: Color = Asset.accentPrimary.swiftUIColor
    public static var baselineOffset: CGFloat = 0
}

public enum RoundedButtonAlertMediumStyle: RoundedButtonStyle {
    public static var fontName: String = FontFamily.Overpass.regular.name
    public static var fontSize: CGFloat = 12
    public static var cornerRadius: CGFloat = 10
    public static var foregroundColor: SwiftUI.Color = Asset.systemRed.swiftUIColor
    public static var selectedColor: SwiftUI.Color = Asset.systemRed.swiftUIColor
    public static var backgroundColor: SwiftUI.Color = Asset.white.swiftUIColor
    public static var elementsSpacing: CGFloat = 8
    public static var borderWidth: CGFloat = 1
    public static var paddingHorizontal: CGFloat = 16
    public static var paddingVertical: CGFloat = 10
    public static var imageSize: CGFloat = 12
    public static var borderColor: SwiftUI.Color = Asset.systemRed.swiftUIColor
    public static var hoveredForegroundColor: Color = Asset.white.swiftUIColor
    public static var hoveredBackgroundColor: Color = Asset.systemRed.swiftUIColor
    public static var baselineOffset: CGFloat = -2
}

struct RoundedButton<Style: RoundedButtonStyle>: View {
    var title: String
    var imageName: String?
    @Binding var enabled: Bool
    var action: () -> Void

    @State private var hovered: Bool = false

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
                    .baselineOffset(Style.baselineOffset)
                    .lineLimit(1)
            }
            .foregroundColor((enabled && hovered) ? Style.hoveredForegroundColor : Style.foregroundColor)
            .padding(.horizontal, Style.paddingHorizontal)
            .padding(.top, Style.paddingVertical + 1)
            .padding(.bottom, Style.paddingVertical)
            .background((enabled && hovered) ? Style.hoveredBackgroundColor : Style.backgroundColor)
            .cornerRadius(Style.cornerRadius)
            .overlay(RoundedRectangle(cornerRadius: Style.cornerRadius)
                .stroke(Style.borderColor, lineWidth: Style.borderWidth))
        }
        .onHover(perform: { hover in
            hovered = hover
        })
        .focusable(false)
        .buttonStyle(PlainButtonStyle())
        .disabled(!enabled)
    }
}
