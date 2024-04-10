import SwiftUI
//import KeyboardShortcuts

struct CustomContextMenuSection: Identifiable {
    var id = UUID()
    var options: [CustomContextMenuOption]
}

struct CustomContextMenuOption: Identifiable {
    var id = UUID()
    var title: String
    var imageName: String?
//    var shortcut: KeyboardShortcuts.Name?
    var isEnabled: Binding<Bool>
    var action: () -> Void
}

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
//                                        shortcut: .export,
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
//                                        shortcut: .importFiles, 
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
                                            let title = document.project.fileSystem.generateUniqueName(baseName: L10n.newFolder.firstWordCapitalized)
                                            let folder = FileSystemElement(title: title, type: .folder)
                                            document.project.fileSystem.addElement(folder)
                                        }),
                CustomContextMenuOption(title: L10n.createScene.firstWordCapitalized,
                                        imageName: SystemImage.film.rawValue,
                                        isEnabled: .constant(true),
                                        action: {
                                            let folder = FileSystemElement(title: L10n.scene.firstWordCapitalized, type: .scene)
                                            document.project.fileSystem.addElement(folder)
                                        })
            ])
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
//                                        shortcut: .characters,
                                        isEnabled: .getOnly(document.project.scriptFile != nil),
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
//                                        shortcut: .transcribeAll,
                                        isEnabled: .getOnly(document.project.hasUntranscribedFiles),
                                        action: {
                                            document.transcribeFiles()
                                        })
            ]),

            CustomContextMenuSection(options: [
                CustomContextMenuOption(title: L10n.determineScenes.firstWordCapitalized,
                                        imageName: SystemImage.film.rawValue,
                                        isEnabled: .getOnly(document.project.canSortScenes),
                                        action: {
                                            document.matchScenes()
                                        }),
                CustomContextMenuOption(title: L10n.determineTakes.firstWordCapitalized,
                                        imageName: SystemImage.filmStack.rawValue,
                                        isEnabled: .getOnly(document.project.hasUnmatchedSortedFiles),
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
//        configureShortcuts(for: base)
//        configureShortcuts(for: file)
//        configureShortcuts(for: edit)
//        configureShortcuts(for: script)
//        configureShortcuts(for: sort)
    }

//    private func configureShortcuts(for menu: [CustomContextMenuSection]) {
//        menu.forEach({ section in
//            section.options.forEach({ option in
//                if let shortcut = option.shortcut {
//                    KeyboardShortcuts.onKeyDown(for: shortcut) {
//                        option.action()
//                    }
//                }
//            })
//        })
//    }
}
