import SwiftUI

public protocol LabelStyle {
    static var fontName: String { get }
    static var fontSize: CGFloat { get }
}

public enum CaptionStyle: LabelStyle {
    public static var fontName: String = FontFamily.Limelight.regular.name
    public static var fontSize: CGFloat = 28
}

public enum Header1Style: LabelStyle {
    public static var fontName: String = FontFamily.NunitoSans.bold.name
    public static var fontSize: CGFloat = 24
}

public enum Header2Style: LabelStyle {
    public static var fontName: String = FontFamily.NunitoSans.bold.name
    public static var fontSize: CGFloat = 20
}

public enum Header3Style: LabelStyle {
    public static var fontName: String = FontFamily.NunitoSans.bold.name
    public static var fontSize: CGFloat = 16
}

public enum BodyLargeStyle: LabelStyle {
    public static var fontName: String = FontFamily.Overpass.regular.name
    public static var fontSize: CGFloat = 16
}

public enum BodyMediumStyle: LabelStyle {
    public static var fontName: String = FontFamily.Overpass.regular.name
    public static var fontSize: CGFloat = 14
}

public enum BodySmallStyle: LabelStyle {
    public static var fontName: String = FontFamily.Overpass.regular.name
    public static var fontSize: CGFloat = 12
}

struct Label<Style: LabelStyle>: View {
    var text: String

    var body: some View {
            Text(text)
                .font(.custom(Style.fontName, size: Style.fontSize))
    }
}
