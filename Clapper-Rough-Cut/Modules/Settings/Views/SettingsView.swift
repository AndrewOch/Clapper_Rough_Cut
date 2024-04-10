import SwiftUI
//import KeyboardShortcuts

struct SettingsView: View {
    
    var body: some View {
        HSplitView {
            LazyVStack {
                Spacer()
            }
            .frame(minWidth: 200, idealWidth: 200, maxWidth: 250)
            .frame(minHeight: 500, idealHeight: 600, maxHeight: 800)
            .padding()
            .background(Asset.surfaceTertiary.swiftUIColor)
            LazyVStack {
                HStack {
                    Spacer()
                    Form {
//                        KeyboardShortcuts.Recorder(L10n.shortcutOpenCharactersMenu, name: .characters)
//                        KeyboardShortcuts.Recorder(L10n.shortcutTranscribeAll, name: .transcribeAll)
//                        KeyboardShortcuts.Recorder(L10n.shortcutExport, name: .export)
                    }
                }
                Spacer()
            }
            .frame(minWidth: 300, idealWidth: 600, maxWidth: 800)
            .frame(minHeight: 500, idealHeight: 600, maxHeight: 800)
            .padding()
            .background(Asset.surfaceSecondary.swiftUIColor)
        }
    }
}
