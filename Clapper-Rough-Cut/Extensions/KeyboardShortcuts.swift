import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let importFiles = Self("importFiles", default: Shortcut(.i, modifiers: [.command]))
    
    static let export = Self("export", default: Shortcut(.e, modifiers: [.command, .shift]))

    static let characters = Self("characters", default: Shortcut(.y, modifiers: [.command]))

    static let transcribeAll = Self("transcribeAll", default: Shortcut(.t, modifiers: [.command, .shift]))
}
