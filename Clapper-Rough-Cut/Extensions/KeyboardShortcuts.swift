import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let export = Self("export", default: Shortcut(.e, modifiers: [.command, .shift]))

    static let characters = Self("characters", default: Shortcut(.y, modifiers: [.command]))

    static let transcribe = Self("transcribe", default: Shortcut(.t, modifiers: [.command, .shift]))
}
