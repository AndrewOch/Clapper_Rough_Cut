import Foundation

protocol ScenesMatchOperations {
    func matchScenes()
    func matchSceneForFile(_ file: FileSystemElement)
    func manualMatch(element: FileSystemElement, phrase: Phrase)
}

// MARK: - Scenes Match Operations
extension ClapperRoughCutDocument: ScenesMatchOperations {

    func matchScenes() {
        registerUndo()
        let files = project.findAllFileSystemElements(where: { $0.isFile })
        matchFor(files: files)
    }

    func matchSceneForFile(_ file: FileSystemElement) {
        registerUndo()
        matchFor(files: [file])
    }

    func manualMatch(element: FileSystemElement, phrase: Phrase) {
        registerUndo()
        match(element: element, phrase: phrase)
    }

    func changePhrase(for scene: FileSystemElement, phrase: Phrase) {
        registerUndo()
        var newScene = scene
        newScene.scriptPhraseId = phrase.id
        if let characterName = phrase.character?.name, let phraseText = phrase.phraseText {
            newScene.title = createPhraseFolderTitle(characterName: characterName, text: phraseText)
        }
        project.updateFileSystemElement(withID: scene.id, newValue: newScene)
    }

    private func matchFor(files: [FileSystemElement]) {
        phraseMatcher.matchFilesToPhrases(files: files,
                                          phrases: project.scriptFile?.blocks.flatMap({ block in block.phrases }) ?? []) { file, phrase in
            self.manualMatch(element: file, phrase: phrase)
        }
    }

    private func createPhraseFolderTitle(characterName: String, text: String) -> String {
        let punctuation = CharacterSet.punctuationCharacters.union(CharacterSet.symbols)
        let cleanedString = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: punctuation).joined(separator: "")
        let words = cleanedString.components(separatedBy: .whitespacesAndNewlines)
        return "\(characterName)-\(words.prefix(10).joined(separator: " "))"
    }

    private func match(element: FileSystemElement, phrase: Phrase) {
        guard var scene = project.firstFileSystemElement(where: { $0.isScene && $0.scriptPhraseId == phrase.id }) else {
            if let characterName = phrase.character?.name, let phraseText = phrase.phraseText {
                guard let folder = project.getContainer(forElementWithID: element.id) else { return }
                var scene = FileSystemElement(title: self.createPhraseFolderTitle(characterName: characterName,
                                                                                  text: phraseText),
                                              type: .scene)
                project.addElement(scene, toFolderWithID: folder.id)
                project.moveFileSystemElement(withID: element.id, toFolderWithID: scene.id)
            }
            return
        }
        project.moveFileSystemElement(withID: element.id, toFolderWithID: scene.id)
    }
}
