import SwiftUI

extension SwiftUI.Font {
    public static let buttonPrimary: SwiftUI.Font = .custom(FontFamily.Overpass.regular.name, size: CustomTextStyle.buttonPrimary.size)
}

enum CustomTextStyle {
    case buttonPrimary
}

extension CustomTextStyle {
    var size: CGFloat {
        switch self {
        case .buttonPrimary: return 12
        }
    }
}
