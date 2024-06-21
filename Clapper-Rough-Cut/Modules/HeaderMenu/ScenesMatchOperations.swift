import Foundation

protocol ScenesMatchOperations {
    func matchScenes()
    func matchSceneForFile(_ file: FileSystemElement)
    func manualMatch(element: FileSystemElement, phrase: ScriptBlockElement)
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

    func manualMatch(element: FileSystemElement, phrase: ScriptBlockElement) {
        registerUndo()
        var updated = element
        updated.tScriptPhraseId = phrase.id
        project.fileSystem.updateElement(withID: element.id, newValue: updated)
        match(element: updated, scene: phrase)
    }

    func changePhrase(for scene: FileSystemElement, phrase: ScriptBlockElement) {
        registerUndo()
        var newScene = scene
        newScene.scriptPhraseId = phrase.id
        if let characterName = phrase.character?.name, let phraseText = phrase.phraseText {
            newScene.title = createPhraseFolderTitle(characterName: characterName, text: phraseText)
        }
        project.fileSystem.updateElement(withID: scene.id, newValue: newScene)
    }

    private func matchFor(files: [FileSystemElement]) {
        guard let scriptFile = project.scriptFile else { return }
        var filtered = files.filter({ !project.fileSystem.getContainer(forElementWithID: $0.id)!.isScene && ($0.audioClasses ?? []).isNotEmpty })

        var phraseFiles = [FileSystemElement]()
        var actionFiles = [FileSystemElement]()
        var speechConfidences: [Float] = []

        for file in filtered {
            if let speechClass = (file.audioClasses ?? []).first(where: { $0.className == "speech" }) {
                if file.tScriptPhraseId != nil {
                    speechConfidences.append(speechClass.confidence)
                }
                if (file.type == .audio && speechClass.confidence > 0.3) || (file.type == .video && speechClass.confidence > 0.6) {
                    phraseFiles.append(file)
                    continue
                }
                actionFiles.append(file)
            }
        }

        if let minConfidence = speechConfidences.min(), let maxConfidence = speechConfidences.max() {
            print("Минимальная уверенность в классе 'speech': \(minConfidence)")
            print("Максимальная уверенность в классе 'speech': \(maxConfidence)")
        } else {
            print("Нет файлов с классом 'speech' и tScriptPhraseId != nil")
        }

        let filteredPhraseFiles = phraseFiles.filter({ $0.subtitles != nil && ($0.subtitles ?? []).isNotEmpty })

        phraseMatcher.match(files: filteredPhraseFiles, phrases: scriptFile.allPhrases, projectId: project.id) { result in
            switch result {
            case .success(let match):
                self.match(element: match.0, scene: match.1)
            case .failure(let error):
                print("Ошибка при сопоставлении: \(error.localizedDescription)")
                guard var updatedFile = self.project.fileSystem.elementById(error.fileId) else { return }
                updatedFile.marker = updatedFile.tScriptPhraseId == nil ? .blue : .yellow
                self.project.fileSystem.updateElement(withID: error.fileId, newValue: updatedFile)
            }
        }

//        actionMatcher.match(files: filteredPhraseFiles, actions: scriptFile.allPhrases, projectId: project.id) { result in
//            switch result {
//            case .success(let match):
//                self.match(element: match.0, scene: match.1)
//            case .failure(let error):
//                print("Ошибка при сопоставлении: \(error.localizedDescription)")
//                guard var updatedFile = self.project.fileSystem.elementById(error.fileId) else { return }
//                updatedFile.marker = updatedFile.tScriptPhraseId == nil ? .blue : .yellow
//                self.project.fileSystem.updateElement(withID: error.fileId, newValue: updatedFile)
//            }
//        }
    }

    private func createPhraseFolderTitle(characterName: String, text: String) -> String {
        let punctuation = CharacterSet.punctuationCharacters.union(CharacterSet.symbols)
        let cleanedString = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: punctuation).joined(separator: "")
        let words = cleanedString.components(separatedBy: .whitespacesAndNewlines)
        return "\(characterName)-\(words.prefix(8).joined(separator: " "))"
    }

    public func cleanScenes() {
        registerUndo()
        project.fileSystem.allElements(where: { $0.isFile }).forEach { file in
            project.fileSystem.moveElement(withID: file.id, toFolderWithID: project.fileSystem.root.id)
        }
        project.fileSystem.allElements(where: { $0.isScene }).forEach { scene in
            _ = project.fileSystem.deleteElement(by: scene.id)
        }
    }

    private func match(element: FileSystemElement, scene: ScriptBlockElement) {
        var updated = element
        if element.tScriptPhraseId != nil {
            updated.marker = element.tScriptPhraseId == scene.id ? .green : .red
        } else {
            updated.marker = .purple
        }

        guard let scene = project.fileSystem.firstElement(where: { $0.isScene && $0.scriptPhraseId == scene.id }) else {
            guard let characterName = scene.character?.name,
                    let phraseText = scene.phraseText,
                  let folder = project.fileSystem.getContainer(forElementWithID: element.id) else { return }
            let scene = FileSystemElement(title: self.createPhraseFolderTitle(characterName: characterName,
                                                                              text: phraseText),
                                          type: .scene,
                                          scriptPhraseId: scene.id)
            project.fileSystem.addElement(scene, toFolderWithID: folder.id)
            project.fileSystem.updateElement(withID: element.id, newValue: updated)
            project.fileSystem.moveElement(withID: element.id, toFolderWithID: scene.id)
            print(project.fileSystem.allElements(where: { $0.tScriptPhraseId != nil }).count)
            return
        }
        project.fileSystem.updateElement(withID: element.id, newValue: updated)
        project.fileSystem.moveElement(withID: element.id, toFolderWithID: scene.id)
    }
}
