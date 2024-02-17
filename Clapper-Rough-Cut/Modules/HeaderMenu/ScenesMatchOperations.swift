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
        let files = project.fileSystem.allElements(where: { $0.isFile })
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
        project.fileSystem.updateElement(withID: scene.id, newValue: newScene)
    }

    private func matchFor(files: [FileSystemElement]) {
        phraseMatcher.match(files: files, projectId: project.id) { result in
            switch result {
            case .success(let matches):
                for (file, phrase) in matches {
                    self.manualMatch(element: file, phrase: phrase)
                }
            case .failure(let error):
                print("Ошибка при сопоставлении: \(error)")
            }
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
        guard let scene = project.fileSystem.firstElement(where: { $0.isScene && $0.scriptPhraseId == phrase.id }) else {
            guard let characterName = phrase.character?.name,
                    let phraseText = phrase.phraseText,
                  let folder = project.fileSystem.getContainer(forElementWithID: element.id) else { return }
            let scene = FileSystemElement(title: self.createPhraseFolderTitle(characterName: characterName,
                                                                              text: phraseText),
                                          type: .scene,
                                          scriptPhraseId: phrase.id)
            project.fileSystem.addElement(scene, toFolderWithID: folder.id)
            project.fileSystem.updateElement(withID: element.id, newValue: element)
            project.fileSystem.moveElement(withID: element.id, toFolderWithID: scene.id)
            return
        }
        project.fileSystem.updateElement(withID: element.id, newValue: element)
        project.fileSystem.moveElement(withID: element.id, toFolderWithID: scene.id)
    }
}
