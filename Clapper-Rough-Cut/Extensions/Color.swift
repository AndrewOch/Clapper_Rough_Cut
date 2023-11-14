import SwiftUI

extension Color {
    public static func contentPrimary(_ colorScheme: ColorScheme) -> Color {
        return (colorScheme == .dark) ? Asset.white.swiftUIColor : Asset.dark.swiftUIColor
    }

    public static func contentSecondary(_ colorScheme: ColorScheme) -> Color {
        return (colorScheme == .dark) ? Asset.semiWhite.swiftUIColor : Asset.semiDark.swiftUIColor
    }

    public static func contentTertiary(_ colorScheme: ColorScheme) -> Color {
        return (colorScheme == .dark) ? Asset.light.swiftUIColor : Asset.tertiary.swiftUIColor
    }

    public static func surfacePrimary(_ colorScheme: ColorScheme) -> Color {
        return (colorScheme == .dark) ? Asset.dark.swiftUIColor : Asset.white.swiftUIColor
    }

    public static func surfaceSecondary(_ colorScheme: ColorScheme) -> Color {
        return (colorScheme == .dark) ? Asset.semiDark.swiftUIColor : Asset.semiWhite.swiftUIColor
    }

    public static func surfaceTertiary(_ colorScheme: ColorScheme) -> Color {
        return (colorScheme == .dark) ? Asset.tertiary.swiftUIColor : Asset.light.swiftUIColor
    }
}

extension Color {
    func interpolated(to color: Color, fraction: CGFloat) -> Color {
        let clampedFraction = min(max(0, fraction), 1)
        let fromNSColor = NSColor(self)
        let toNSColor = NSColor(color)
        guard let fromComponents = fromNSColor.cgColor.components,
              let toComponents = toNSColor.cgColor.components,
              fromComponents.count >= 3,
              toComponents.count >= 3 else {
            return self
        }
        let red = fromComponents[0] + (toComponents[0] - fromComponents[0]) * clampedFraction
        let green = fromComponents[1] + (toComponents[1] - fromComponents[1]) * clampedFraction
        let blue = fromComponents[2] + (toComponents[2] - fromComponents[2]) * clampedFraction
        let alpha = fromComponents.count > 3 ? fromComponents[3] + (toComponents[3] - fromComponents[3]) * clampedFraction : 1
        return Color(red: Double(red), green: Double(green), blue: Double(blue), opacity: Double(alpha))
    }
}
