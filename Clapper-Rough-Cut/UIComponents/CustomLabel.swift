import SwiftUI

public protocol LabelStyle {
    static var fontName: String { get }
    static var fontSize: CGFloat { get }
    static var baselineOffset: CGFloat { get }
}

public enum CaptionStyle: LabelStyle {
    public static var fontName: String = FontFamily.Limelight.regular.name
    public static var fontSize: CGFloat = 28
    public static var baselineOffset: CGFloat = 0
}

public enum Header1Style: LabelStyle {
    public static var fontName: String = FontFamily.NunitoSans.bold.name
    public static var fontSize: CGFloat = 24
    public static var baselineOffset: CGFloat = 0
}

public enum Header2Style: LabelStyle {
    public static var fontName: String = FontFamily.NunitoSans.bold.name
    public static var fontSize: CGFloat = 20
    public static var baselineOffset: CGFloat = 0
}

public enum Header3Style: LabelStyle {
    public static var fontName: String = FontFamily.NunitoSans.bold.name
    public static var fontSize: CGFloat = 16
    public static var baselineOffset: CGFloat = 0
}

public enum BodyLargeStyle: LabelStyle {
    public static var fontName: String = FontFamily.NunitoSans.regular.name
    public static var fontSize: CGFloat = 16
    public static var baselineOffset: CGFloat = -4
}

public enum BodyMediumStyle: LabelStyle {
    public static var fontName: String = FontFamily.NunitoSans.regular.name
    public static var fontSize: CGFloat = 14
    public static var baselineOffset: CGFloat = -4
}

public enum BodySmallStyle: LabelStyle {
    public static var fontName: String = FontFamily.NunitoSans.regular.name
    public static var fontSize: CGFloat = 12
    public static var baselineOffset: CGFloat = -4
}

struct CustomLabel<Style: LabelStyle>: View {
    @State var text: String

    var body: some View {
        Text(text)
            .font(.custom(Style.fontName, size: Style.fontSize))
            .baselineOffset(Style.baselineOffset)
    }
}

struct CustomBindedLabel<Style: LabelStyle>: View {
    @Binding var text: String

    var body: some View {
        Text(text)
            .font(.custom(Style.fontName, size: Style.fontSize))
            .baselineOffset(Style.baselineOffset)
    }
}
