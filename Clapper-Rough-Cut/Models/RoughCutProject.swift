import Foundation

struct RoughCutProject: Identifiable, Codable {
    var id = UUID()
    var scriptFile: ScriptFile? {
        didSet {
            updateScriptFile()
        }
    }
    var fileSystem: RoughCutFileSystem = RoughCutFileSystem()
    var exportSettings: ExportSettings = ExportSettings()

    func syncToServer() {
        updateScriptFile()
    }

    private func updateScriptFile() {
        guard let scriptFile = scriptFile else { return }
        guard let url = URL(string: "\(EnvironmentVariables.baseUrl)/script") else { return }

        let body = [
            "project_id": id.uuidString,
            "script_id": scriptFile.id.uuidString,
            "file_path": scriptFile.url.absoluteString,
            "phrases": scriptFile.allPhrases.map({ $0.dictionaryRepresentation }),
            "actions": scriptFile.allActions.map({ $0.dictionaryRepresentation }),
            "character_names": scriptFile.characters.map({ $0.name })
        ] as [String : Any]

        guard let requestData = try? JSONSerialization.data(withJSONObject: body, options: []) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestData

        DispatchQueue.global(qos: .userInitiated).async {
            let task = URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        print("Ошибка при обновлении scriptFile: \(error)")
                    }
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    DispatchQueue.main.async {
                        print("Ошибка: Неверный статус ответа")
                    }
                    return
                }
                DispatchQueue.main.async {
                    print("ScriptFile успешно обновлен на сервере")
                }
            }
            task.resume()
        }
    }
}

// MARK: - Project states
extension RoughCutProject {
    var hasUnanalizedFiles: Bool {
        return hasUntranscribedFiles || hasUnclassifiedAudios || hasUnclassifiedVideos
    }
    var hasUntranscribedFiles: Bool {
        return fileSystem.allElements(where: { $0.isFile && $0.subtitles == nil }).isNotEmpty
    }
    var hasUnclassifiedAudios: Bool {
        return fileSystem.allElements(where: { $0.isFile && $0.audioClasses == nil }).isNotEmpty
    }
    var hasUnclassifiedVideos: Bool {
        return fileSystem.allElements(where: { $0.type == .video && $0.videoClasses == nil }).isNotEmpty
    }
    var hasUnsortedTranscribedFiles: Bool {
        return fileSystem.allElements(where: { $0.isFile && $0.subtitles != nil }).isNotEmpty
    }
    var canSortScenes: Bool {
        return hasUnsortedTranscribedFiles && scriptFile != nil
    }
    var hasUnmatchedSortedFiles: Bool {
        fileSystem.firstElement { scene in
            scene.isScene &&
            fileSystem.firstElement(where: { $0.containerId == scene.id && $0.type == .audio }) != nil &&
            fileSystem.firstElement(where: { $0.containerId == scene.id && $0.type == .video }) != nil
        } != nil
    }
}
