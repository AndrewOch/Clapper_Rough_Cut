import SwiftUI

enum KeyboardShortcuts {
    static let importFiles = KeyboardShortcut(KeyEquivalent("i"), modifiers: [.command])
    static let export = KeyboardShortcut(KeyEquivalent("e"), modifiers: [.command, .shift])
    static let characters = KeyboardShortcut(KeyEquivalent("y"), modifiers: [.command])
    static let transcribeAll = KeyboardShortcut(KeyEquivalent("t"), modifiers: [.command, .shift])
}
