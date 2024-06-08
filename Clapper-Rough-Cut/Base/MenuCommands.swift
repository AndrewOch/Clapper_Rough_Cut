import SwiftUI

struct DocumentFocusedValueKey: FocusedValueKey {
    typealias Value = Binding<ClapperRoughCutDocument>
}

extension FocusedValues {
    var document: DocumentFocusedValueKey.Value? {
        get { return self[DocumentFocusedValueKey.self] }
        set { self[DocumentFocusedValueKey.self] = newValue }
    }
}

struct ClapperRoughCutCommands: Commands {
    @FocusedBinding(\.document) var document: ClapperRoughCutDocument?

    var body: some Commands {
        exportGroup
        importGroup
        scriptMenu
        sortMenu
    }

    var exportGroup: some Commands {
        CommandGroup(after: .saveItem) {
            Divider()
            Button(L10n.export.firstWordCapitalized) {
                document?.states.isExportViewPresented.toggle()
            }
            .keyboardShortcut(KeyboardShortcuts.export)
            Divider()
        }
    }

    var importGroup: some Commands {
        CommandGroup(before: .undoRedo) {
            Button(L10n.addFiles.firstWordCapitalized) {
                document?.addRawFiles()
            }
            .keyboardShortcut(KeyboardShortcuts.importFiles)
            Button(L10n.addFolder.firstWordCapitalized) {

            }
            Menu(L10n.create.capitalized) {
                Button(action: {
                    guard let title = document?.project.fileSystem.generateUniqueName(baseName: L10n.newFolder.firstWordCapitalized) else { return }
                    let folder = FileSystemElement(title: title, type: .folder)
                    document?.project.fileSystem.addElement(folder)
                }) {
                    Text(L10n.folder.firstWordCapitalized)
                    SystemImage.folderFill.imageView
                }
                Button(action: {
                    let folder = FileSystemElement(title: L10n.scene.firstWordCapitalized, type: .scene)
                    document?.project.fileSystem.addElement(folder)
                }) {
                    Text(L10n.scene.firstWordCapitalized)
                    SystemImage.film.imageView
                }
            }
            Divider()
        }
    }

    var scriptMenu: some Commands {
        CommandMenu(L10n.script.firstWordCapitalized) {
            Button(L10n.addScript.firstWordCapitalized) {
                document?.addScriptFile()
            }
            Button(L10n.characters.firstWordCapitalized) {
                document?.states.isCharactersViewPresented.toggle()
            }
            .keyboardShortcut(KeyboardShortcuts.characters)
            .disabled(document?.project.scriptFile == nil)
        }
    }

    var sortMenu: some Commands {
        CommandMenu(L10n.sort.firstWordCapitalized) {
            Button(L10n.analyze.firstWordCapitalized) {
                document?.analizeFiles()
            }
            .keyboardShortcut(KeyboardShortcuts.transcribeAll)
            .disabled(!(document?.project.hasUnanalizedFiles ?? false))

            Menu(L10n.analysis.firstWordCapitalized) {
                Button(L10n.transcribe.firstWordCapitalized) {
                    document?.transcribeFiles()
                }
                .disabled(!(document?.project.hasUntranscribedFiles ?? false))
                Button(L10n.classifyVideos.firstWordCapitalized) {
                    document?.classifyVideos()
                }
                .disabled(!(document?.project.hasUnclassifiedVideos ?? false))
                Button(L10n.classifyAudio.firstWordCapitalized) {
                    document?.classifyAudios()
                }
                .disabled(!(document?.project.hasUnclassifiedAudios ?? false))
            }

            Divider()
            Button(L10n.determineScenes.firstWordCapitalized) {
                document?.matchScenes()
            }
            Button("Сбросить сортировку") {
                document?.cleanScenes()
            }
            Divider()
            .disabled(!(document?.project.canSortScenes ?? false))
            Button(L10n.determineTakes.firstWordCapitalized) {
                document?.matchTakes()
            }
            .disabled(!(document?.project.hasUnmatchedSortedFiles ?? false))
        }
    }
}
