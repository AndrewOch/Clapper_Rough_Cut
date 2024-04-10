import SwiftUI
import AppKit

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

extension Color {
    init?(hex: String) {
        let r, g, b: Double
        let start = hex.hasPrefix("#") ? hex.index(hex.startIndex, offsetBy: 1) : hex.startIndex
        let hexColor = String(hex[start...])

        if hexColor.count == 6 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0

            if scanner.scanHexInt64(&hexNumber) {
                r = Double((hexNumber & 0xff0000) >> 16) / 255
                g = Double((hexNumber & 0x00ff00) >> 8) / 255
                b = Double(hexNumber & 0x0000ff) / 255

                self.init(red: r, green: g, blue: b)
                return
            }
        }
        return nil
    }

    // swiftlint:disable large_tuple
    func components() -> (red: Double, green: Double, blue: Double, alpha: Double) {
        let uiColor = NSColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (Double(red), Double(green), Double(blue), Double(alpha))
    }
    // swiftlint:enable large_tuple

    static var random: Color {
        let red = Double.random(in: 0.5...1)
        let green = Double.random(in: 0.5...1)
        let blue = Double.random(in: 0.5...1)
        return Color(red: red, green: green, blue: blue)
    }
}
