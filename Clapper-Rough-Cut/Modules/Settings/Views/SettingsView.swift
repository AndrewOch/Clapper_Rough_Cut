import SwiftUI
import KeyboardShortcuts

struct SettingsView: View {
    var body: some View {
        Form {
            KeyboardShortcuts.Recorder("Export:", name: .export)
        }
    }
}
