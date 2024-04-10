// swiftlint:disable all
// Generated using SwiftGen — <https://github.com/SwiftGen/SwiftGen>

#if os(OSX)
  import AppKit.NSFont
  internal typealias Font = NSFont
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIFont
  internal typealias Font = UIFont
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Fonts

// swiftlint:disable identifier_name line_length type_body_length
internal enum FontFamily {
  internal enum Limelight {
    internal static let regular = FontConvertible(name: "Limelight-Regular", family: "Limelight", path: "Limelight-Regular.ttf")
    internal static let all: [FontConvertible] = [regular]
  }
  internal enum NotoSans {
    internal static let bold = FontConvertible(name: "NotoSans-Bold", family: "Noto Sans", path: "NotoSans-Bold.ttf")
    internal static let regular = FontConvertible(name: "NotoSans-Regular", family: "Noto Sans", path: "NotoSans-Regular.ttf")
    internal static let semiBold = FontConvertible(name: "NotoSans-SemiBold", family: "Noto Sans", path: "NotoSans-SemiBold.ttf")
    internal static let all: [FontConvertible] = [bold, regular, semiBold]
  }
  internal enum NunitoSans {
    internal static let _12ptExtraLight = FontConvertible(name: "NunitoSans-12ptExtraLight", family: "Nunito Sans", path: "NunitoSans.ttf")
    internal static let black = FontConvertible(name: "NunitoSans-12ptExtraLight_Black", family: "Nunito Sans", path: "NunitoSans.ttf")
    internal static let bold = FontConvertible(name: "NunitoSans-12ptExtraLight_Bold", family: "Nunito Sans", path: "NunitoSans.ttf")
    internal static let extraBold = FontConvertible(name: "NunitoSans-12ptExtraLight_ExtraBold", family: "Nunito Sans", path: "NunitoSans.ttf")
    internal static let light = FontConvertible(name: "NunitoSans-12ptExtraLight_Light", family: "Nunito Sans", path: "NunitoSans.ttf")
    internal static let medium = FontConvertible(name: "NunitoSans-12ptExtraLight_Medium", family: "Nunito Sans", path: "NunitoSans.ttf")
    internal static let regular = FontConvertible(name: "NunitoSans-12ptExtraLight_Regular", family: "Nunito Sans", path: "NunitoSans.ttf")
    internal static let semiBold = FontConvertible(name: "NunitoSans-12ptExtraLight_SemiBold", family: "Nunito Sans", path: "NunitoSans.ttf")
    internal static let all: [FontConvertible] = [_12ptExtraLight, black, bold, extraBold, light, medium, regular, semiBold]
  }
  internal static let allCustomFonts: [FontConvertible] = [Limelight.all, NotoSans.all, NunitoSans.all].flatMap { $0 }
  internal static func registerAllCustomFonts() {
    allCustomFonts.forEach { $0.register() }
  }
}
// swiftlint:enable identifier_name line_length type_body_length

// MARK: - Implementation Details

internal struct FontConvertible {
  internal let name: String
  internal let family: String
  internal let path: String

  internal func font(size: CGFloat) -> Font {
    guard let font = Font(font: self, size: size) else {
      fatalError("Unabble to initialize font '\\(name)' (\\(family))")
    }
    return font
  }

  internal func register() {
    // swiftlint:disable:next conditional_returns_on_newline
    guard let url = url else { return }
    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
  }

  fileprivate var url: URL? {
    let bundle = BundleToken.bundle
    return bundle.url(forResource: path, withExtension: nil)
  }
}

internal extension Font {
  convenience init?(font: FontConvertible, size: CGFloat) {
    #if os(iOS) || os(tvOS) || os(watchOS)
    if !UIFont.fontNames(forFamilyName: font.family).contains(font.name) {
      font.register()
    }
    #elseif os(OSX)
    if let url = font.url, CTFontManagerGetScopeForURL(url as CFURL) == .none {
      font.register()
    }
    #endif

    self.init(name: font.name, size: size)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    Bundle(for: BundleToken.self)
  }()
}
// swiftlint:enable convenience_type
