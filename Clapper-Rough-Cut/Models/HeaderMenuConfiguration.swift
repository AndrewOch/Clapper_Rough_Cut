import SwiftUI
import KeyboardShortcuts

struct HeaderMenuConfiguration {
    var document: ClapperRoughCutDocument

    public var base: [CustomContextMenuSection] {
        return [
            CustomContextMenuSection(options: [
                CustomContextMenuOption(title: L10n.settings.firstWordCapitalized,
                                        imageName: SystemImage.gearshape.rawValue,
                                        isEnabled: .constant(true),
                                        action: {

                                        })
            ])
        ]
    }

    public var file: [CustomContextMenuSection] {
        return [
            CustomContextMenuSection(options: [
                CustomContextMenuOption(title: L10n.export.capitalized,
                                        imageName: SystemImage.rectanglePortraitAndArrowRight.rawValue,
                                        shortcut: .export,
                                        isEnabled: .constant(true),
                                        action: {
                                            document.states.isExportViewPresented.toggle()
                                        })
            ])
        ]
    }

    public var edit: [CustomContextMenuSection] {
        return [
            CustomContextMenuSection(options: [
                CustomContextMenuOption(title: L10n.addFiles.firstWordCapitalized,
                                        imageName: SystemImage.squareAndArrowDown.rawValue,
                                        isEnabled: .constant(true),
                                        action: {
                                            document.addRawFiles()
                                        }),
                CustomContextMenuOption(title: L10n.addFolder.firstWordCapitalized,
                                        imageName: SystemImage.squareAndArrowDown.rawValue,
                                        isEnabled: .constant(true),
                                        action: {

                                        })
            ]),
            CustomContextMenuSection(options: [
                CustomContextMenuOption(title: L10n.createFolder.firstWordCapitalized,
                                        imageName: SystemImage.folder.rawValue,
                                        isEnabled: .constant(true),
                                        action: {
                                            let folder = FileSystemElement(title: L10n.folder.firstWordCapitalized, type: .folder)
                                            document.project.addElement(folder)
                                        }),
                CustomContextMenuOption(title: L10n.createScene.firstWordCapitalized,
                                        imageName: SystemImage.film.rawValue,
                                        isEnabled: .constant(true),
                                        action: {
                                            let folder = FileSystemElement(title: L10n.scene.firstWordCapitalized, type: .scene)
                                            document.project.addElement(folder)
                                        })
            ])
        ]
    }

    public var search: [CustomContextMenuSection] {
        return [
        ]
    }

    public var script: [CustomContextMenuSection] {
        return [
            CustomContextMenuSection(options: [
                CustomContextMenuOption(title: L10n.addScript.firstWordCapitalized,
                                        imageName: SystemImage.plus.rawValue,
                                        isEnabled: .constant(true),
                                        action: {
                                            document.addScriptFile()
                                        })
            ]),
            CustomContextMenuSection(options: [
                CustomContextMenuOption(title: L10n.characters.firstWordCapitalized,
                                        imageName: SystemImage.person.rawValue,
                                        shortcut: .characters,
                                        isEnabled: .constant(true),
                                        action: {
                                            document.states.isCharactersViewPresented.toggle()
                                        })
            ])
        ]
    }

    public var sort: [CustomContextMenuSection] {
        return [
            CustomContextMenuSection(options: [
                CustomContextMenuOption(title: L10n.transcribe.capitalized,
                                        imageName: SystemImage.rectangleAndPencilAndEllipsis.rawValue,
                                        shortcut: .transcribe,
                                        isEnabled: Binding(get: {
                                            document.project.hasUntranscribedFiles
                                        }, set: { _ in }),
                                        action: {
                                            document.transcribeFiles()
                                        })
            ]),

            CustomContextMenuSection(options: [
                CustomContextMenuOption(title: L10n.determineScenes.firstWordCapitalized,
                                        imageName: SystemImage.film.rawValue,
                                        isEnabled: Binding(get: {
                                            document.project.canSortScenes
                                        }, set: { _ in }),
                                        action: {
                                            document.matchScenes()
                                        }),
                CustomContextMenuOption(title: L10n.determineTakes.firstWordCapitalized,
                                        imageName: SystemImage.filmStack.rawValue,
                                        isEnabled: Binding(get: {
                                            document.project.hasUnmatchedSortedFiles
                                        }, set: { _ in }),
                                        action: {
                                            document.matchTakes()
                                        })
            ])
        ]
    }

    init(document: ClapperRoughCutDocument) {
        self.document = document
        configureShortcuts()
    }

    private func configureShortcuts() {
        configureShortcuts(for: base)
        configureShortcuts(for: file)
        configureShortcuts(for: edit)
        configureShortcuts(for: search)
        configureShortcuts(for: script)
        configureShortcuts(for: sort)
    }

    private func configureShortcuts(for menu: [CustomContextMenuSection]) {
        menu.forEach({ section in
            section.options.forEach({ option in
                if let shortcut = option.shortcut {
                    KeyboardShortcuts.onKeyDown(for: shortcut) {
                        option.action()
                    }
                }
            })
        })
    }
}

struct CustomContextMenuSection: Identifiable {
    var id = UUID()
    var options: [CustomContextMenuOption]
}

struct CustomContextMenuOption: Identifiable {
    var id = UUID()
    var title: String
    var imageName: String?
    var shortcut: KeyboardShortcuts.Name?
    var isEnabled: Binding<Bool>
    var action: () -> Void
}
