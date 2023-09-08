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
  internal enum Overpass {
    internal static let regular = FontConvertible(name: "Overpass-Regular", family: "Overpass", path: "Overpass.ttf")
    internal static let black = FontConvertible(name: "OverpassRoman-Black", family: "Overpass", path: "Overpass.ttf")
    internal static let bold = FontConvertible(name: "OverpassRoman-Bold", family: "Overpass", path: "Overpass.ttf")
    internal static let extraBold = FontConvertible(name: "OverpassRoman-ExtraBold", family: "Overpass", path: "Overpass.ttf")
    internal static let extraLight = FontConvertible(name: "OverpassRoman-ExtraLight", family: "Overpass", path: "Overpass.ttf")
    internal static let light = FontConvertible(name: "OverpassRoman-Light", family: "Overpass", path: "Overpass.ttf")
    internal static let medium = FontConvertible(name: "OverpassRoman-Medium", family: "Overpass", path: "Overpass.ttf")
    internal static let semiBold = FontConvertible(name: "OverpassRoman-SemiBold", family: "Overpass", path: "Overpass.ttf")
    internal static let thin = FontConvertible(name: "OverpassRoman-Thin", family: "Overpass", path: "Overpass.ttf")
    internal static let all: [FontConvertible] = [regular, black, bold, extraBold, extraLight, light, medium, semiBold, thin]
  }
  internal static let allCustomFonts: [FontConvertible] = [Overpass.all].flatMap { $0 }
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
