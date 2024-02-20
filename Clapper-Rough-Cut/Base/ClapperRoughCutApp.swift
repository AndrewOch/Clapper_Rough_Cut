import SwiftUI
import AppKit

@main
struct ClapperRoughCutApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: { ClapperRoughCutDocument() }) { file in
            ContentView()
                .environmentObject(file.document)
                .focusedSceneValue(\.document, .getOnly(file.document))
        }
        .commands {
            ClapperRoughCutCommands()
        }
        Settings {
            SettingsView()
        }
    }
}
