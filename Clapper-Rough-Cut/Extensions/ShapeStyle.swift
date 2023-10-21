import SwiftUI

extension Color {
    public static func contentPrimary(_ colorScheme: ColorScheme) -> Color {
        return (colorScheme == .dark) ? Asset.white.swiftUIColor : Asset.dark.swiftUIColor
    }

    public static func contentSecondary(_ colorScheme: ColorScheme) -> Color {
        return (colorScheme == .dark) ? Asset.semiWhite.swiftUIColor : Asset.semiDark.swiftUIColor
    }
    
    public static func contentTertiary(_ colorScheme: ColorScheme) -> Color {
        return (colorScheme == .dark) ? Asset.secondary.swiftUIColor : Asset.light.swiftUIColor
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
