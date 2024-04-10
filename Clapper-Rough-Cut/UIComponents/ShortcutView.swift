import SwiftUI
//import KeyboardShortcuts

//TODO: - Fix Shortcuts
struct ShortcutView: View {
//    @State var shortcut: KeyboardShortcuts.Name.Shortcut

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            if #available(macOS 13.0, *) {
                CustomLabel<BodyMediumStyle>(text: "shortcut.description")
                    .kerning(2)
            } else {
                CustomLabel<BodyMediumStyle>(text: "shortcut.description")
            }
        }
    }
}
