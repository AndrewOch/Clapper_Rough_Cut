import Foundation

protocol ScenesMatchOperations {
    func matchScenes()
    func matchSceneForFile(_ file: RawFile)
    func manualMatch(file: RawFile, phrase: Phrase)
}

// MARK: - Scenes Match Operations
extension ClapperRoughCutDocument: ScenesMatchOperations {

    func matchScenes() {
        matchFor(files: project.unsortedFolder.files)
    }

    func matchSceneForFile(_ file: RawFile) {
        matchFor(files: [file])
    }

    func manualMatch(file: RawFile, phrase: Phrase) {
        match(file: file, phrase: phrase)
        updateStatus()
    }

    func manualMatch(take: RawTake, phrase: Phrase) {
        match(take: take, phrase: phrase)
        updateStatus()
    }

    func changeScene(for folder: RawFilesFolder, phrase: Phrase) {
        folder.scriptPhraseId = phrase.id
        folder.title = createPhraseFolderTitle(characterName: phrase.characterName, text: phrase.phraseText)
        updateStatus()
    }

    private func matchFor(files: [RawFile]) {
        phraseMatcher.matchFilesToPhrases(files: files,
                                          phrases: project.scriptFile?.blocks.flatMap({ block in block.phrases }) ?? []) { file, phrase in
            self.manualMatch(file: file, phrase: phrase)
        }
        updateStatus()
    }

    private func createPhraseFolderTitle(characterName: String, text: String) -> String {
        let punctuation = CharacterSet.punctuationCharacters.union(CharacterSet.symbols)
        let cleanedString = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: punctuation).joined(separator: "")
        let words = cleanedString.components(separatedBy: .whitespacesAndNewlines)
        return "\(characterName)-\(words.prefix(10).joined(separator: " "))"
    }

    private func match(file: RawFile, phrase: Phrase) {
        if let index = self.project.phraseFolders.firstIndex(where: { $0.files.contains { $0.id == file.id }}) {
            project.phraseFolders[index].files.removeAll(where: { $0.id == file.id })
            if project.phraseFolders[index].takes.isEmpty && project.phraseFolders[index].files.isEmpty {
                project.phraseFolders.remove(at: index)
            }
        }
        if let index = self.project.phraseFolders.firstIndex(where: { folder in folder.scriptPhraseId == phrase.id }) {
            self.project.phraseFolders[index].files.append(file)
        } else {
            self.project.phraseFolders.append(RawFilesFolder(title: self.createPhraseFolderTitle(characterName: phrase.characterName,
                                                                                            text: phrase.phraseText),
                                                             files: [file],
                                                             scriptPhraseId: phrase.id))
        }
        self.project.unsortedFolder.files.removeAll { file in file.id == file.id }
    }

    private func match(take: RawTake, phrase: Phrase) {
        if let index = self.project.phraseFolders.firstIndex(where: { $0.takes.contains { $0.id == take.id }}) {
            project.phraseFolders[index].takes.removeAll(where: { $0.id == take.id })
            if project.phraseFolders[index].takes.isEmpty && project.phraseFolders[index].files.isEmpty {
                project.phraseFolders.remove(at: index)
            }
        }
        if let index = self.project.phraseFolders.firstIndex(where: { folder in folder.scriptPhraseId == phrase.id }) {
            self.project.phraseFolders[index].takes.append(take)
        } else {
            self.project.phraseFolders.append(RawFilesFolder(title: self.createPhraseFolderTitle(characterName: phrase.characterName,
                                                                                                 text: phrase.phraseText),
                                                             takes: [take],
                                                             scriptPhraseId: phrase.id))
        }
        self.project.unsortedFolder.takes.removeAll { file in file.id == take.id }
    }
}
