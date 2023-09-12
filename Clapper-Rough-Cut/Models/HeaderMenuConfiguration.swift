import SwiftUI

struct HeaderMenuConfiguration {
    var document: ClapperRoughCutDocument

    public var base: [CustomContextMenuSection] {
        return project
    }

    public var project: [CustomContextMenuSection] {
        return [
            CustomContextMenuSection(options: [
                CustomContextMenuOption(title: L10n.addFiles.firstWordCapitalized,
                                        imageName: SystemImage.squareAndArrowDown.rawValue,
                                        isEnabled: .constant(true),
                                        action: {
                                            document.addRawFiles()
                                        })
            ]),

            CustomContextMenuSection(options: [
                CustomContextMenuOption(title: L10n.export.capitalized,
                                        imageName: SystemImage.rectanglePortraitAndArrowRight.rawValue,
                                        isEnabled: .constant(true),
                                        action: {
                                            document.states.isExportViewPresented.toggle()
                                        }),
                CustomContextMenuOption(title: L10n.export.capitalized,
                                        imageName: SystemImage.rectanglePortraitAndArrowRight.rawValue,
                                        isEnabled: .constant(true),
                                        action: {
                                            document.states.isExportViewPresented.toggle()
                                        }),
                CustomContextMenuOption(title: L10n.export.capitalized,
                                        imageName: SystemImage.rectanglePortraitAndArrowRight.rawValue,
                                        isEnabled: .constant(true),
                                        action: {
                                            document.states.isExportViewPresented.toggle()
                                        })
            ])
        ]
    }

    public var search: [CustomContextMenuSection] {
        return [
            CustomContextMenuSection(options: [
                CustomContextMenuOption(title: L10n.addFiles.firstWordCapitalized,
                                        imageName: SystemImage.squareAndArrowDown.rawValue,
                                        isEnabled: .constant(true),
                                        action: {
                                            document.addRawFiles()
                                        })
            ]),

            CustomContextMenuSection(options: [
                CustomContextMenuOption(title: L10n.export.capitalized,
                                        imageName: SystemImage.rectanglePortraitAndArrowRight.rawValue,
                                        isEnabled: .constant(true),
                                        action: {
                                            document.states.isExportViewPresented.toggle()
                                        }),
                CustomContextMenuOption(title: L10n.export.capitalized,
                                        imageName: SystemImage.rectanglePortraitAndArrowRight.rawValue,
                                        isEnabled: .constant(true),
                                        action: {
                                            document.states.isExportViewPresented.toggle()
                                        })
            ])
        ]
    }

    public var script: [CustomContextMenuSection] {
        return [
            CustomContextMenuSection(options: [
                CustomContextMenuOption(title: L10n.addFiles.firstWordCapitalized,
                                        imageName: SystemImage.squareAndArrowDown.rawValue,
                                        isEnabled: .constant(true),
                                        action: {
                                            document.addRawFiles()
                                        })
            ]),

            CustomContextMenuSection(options: [
                CustomContextMenuOption(title: L10n.export.capitalized,
                                        imageName: SystemImage.rectanglePortraitAndArrowRight.rawValue,
                                        isEnabled: .constant(true),
                                        action: {
                                            document.states.isExportViewPresented.toggle()
                                        })
            ])
        ]
    }

    public var sort: [CustomContextMenuSection] {
        return [
            CustomContextMenuSection(options: [
                CustomContextMenuOption(title: L10n.transcribe.capitalized,
                                        imageName: SystemImage.rectangleAndPencilAndEllipsis.rawValue,
                                        isEnabled: Binding(get: {
                                            document.project.hasUntranscribedFiles
                                        }, set: { value in
                                            document.project.hasUntranscribedFiles = value
                                        }),
                                        action: {
                                            document.transcribeFiles()
                                        })
            ]),

            CustomContextMenuSection(options: [
                CustomContextMenuOption(title: L10n.determineScenes.firstWordCapitalized,
                                        imageName: SystemImage.film.rawValue,
                                        isEnabled: Binding(get: {
                                            document.project.canSortScenes
                                        }, set: { value in
                                            document.project.canSortScenes = value
                                        }),
                                        action: {
                                            document.matchScenes()
                                        }),
                CustomContextMenuOption(title: L10n.determineTakes.firstWordCapitalized,
                                        imageName: SystemImage.filmStack.rawValue,
                                        isEnabled: Binding(get: {
                                            document.project.hasUnmatchedSortedFiles
                                        }, set: { value in
                                            document.project.hasUnmatchedSortedFiles = value
                                        }),
                                        action: {
                                            document.matchTakes()
                                        })
            ])
        ]
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
    var isEnabled: Binding<Bool>
    var action: () -> Void
}
