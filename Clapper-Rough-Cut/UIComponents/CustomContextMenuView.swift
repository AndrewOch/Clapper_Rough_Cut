import SwiftUI

private struct CustomContextMenuButtonStyle {
    public static let fontName: String = FontFamily.Overpass.regular.name
    public static let fontSize: CGFloat = 14
    public static let cornerRadius: CGFloat = 5
    public static let foregroundColor: SwiftUI.Color = Asset.accentPrimary.swiftUIColor
    public static let hoveredForegroundColor: SwiftUI.Color = Asset.white.swiftUIColor
    public static let backgroundColor: SwiftUI.Color = .clear
    public static let hoveredBackgroundColor: SwiftUI.Color = Asset.accentPrimary.swiftUIColor
    public static let elementsSpacing: CGFloat = 0
    public static let borderWidth: CGFloat = 0
    public static let paddingHorizontal: CGFloat = 8
    public static let paddingVertical: CGFloat = 6
    public static let imageSize: CGFloat = 14
    public static let borderColor: SwiftUI.Color = .clear
    public static let baselineOffset: CGFloat = -2
}

struct CustomContextMenuView: View {
    @State var position: CGPoint
    let sections: [CustomContextMenuSection]

    var body: some View {
        OverlayMenu(position: position) {
            VStack(spacing: 5) {
                ForEach(sections) { section in
                    VStack(spacing: 0) {
                        ForEach(section.options) { option in
                            CustomContextMenuOptionButton(option: option)
                        }
                    }
                    if sections.last?.id != section.id {
                        Rectangle()
                            .frame(height: 1)
                            .background(Asset.accentDark.swiftUIColor)
                    }
                }
            }
            .frame(idealWidth: 150, maxWidth: 200)
            .padding(.all, 5)
        }
    }
}

struct CustomContextMenuOptionButton: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @State var option: CustomContextMenuOption
    @State private var hovered: Bool = false

    var body: some View {
        Button(action: {
            option.action()
            document.states.selectedHeaderOption = .none
        }) {
                HStack {
                    if let imageName = option.imageName {
                        Image(systemName: imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: CustomContextMenuButtonStyle.imageSize,
                                   height: CustomContextMenuButtonStyle.imageSize)
                    }
                    Text(option.title)
                        .font(.custom(CustomContextMenuButtonStyle.fontName, size: CustomContextMenuButtonStyle.fontSize))
                        .baselineOffset(CustomContextMenuButtonStyle.baselineOffset)
                        .lineLimit(1)
                    Spacer()
                    if let shortcut = option.shortcut?.shortcut {
                        ShortcutView(shortcut: shortcut)
                    }
                }
                .foregroundColor((option.isEnabled.wrappedValue && hovered) ? CustomContextMenuButtonStyle.hoveredForegroundColor : CustomContextMenuButtonStyle.foregroundColor)
                .padding(.horizontal, CustomContextMenuButtonStyle.paddingHorizontal)
                .padding(.top, CustomContextMenuButtonStyle.paddingVertical + 1)
                .padding(.bottom, CustomContextMenuButtonStyle.paddingVertical)
                .background((option.isEnabled.wrappedValue && hovered) ? CustomContextMenuButtonStyle.hoveredBackgroundColor : CustomContextMenuButtonStyle.backgroundColor)
                .cornerRadius(CustomContextMenuButtonStyle.cornerRadius)
                .overlay(RoundedRectangle(cornerRadius: CustomContextMenuButtonStyle.cornerRadius)
                    .stroke(CustomContextMenuButtonStyle.borderColor, lineWidth: CustomContextMenuButtonStyle.borderWidth))
        }
        .onHover(perform: { hover in
            hovered = hover
        })
        .focusable(false)
        .buttonStyle(PlainButtonStyle())
        .disabled(!option.isEnabled.wrappedValue)
    }
}
