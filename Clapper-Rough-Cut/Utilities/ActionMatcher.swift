import Foundation
import NaturalLanguage

protocol ActionMatcherProtocol {
    func match(files: [FileSystemElement], actions: [ScriptBlockElement], projectId: UUID, completion: @escaping (Result<(FileSystemElement, ScriptBlockElement), SceneMatchError>) -> Void)
    func match(file: FileSystemElement, actions: [ScriptBlockElement], projectId: UUID, completion: @escaping (Result<(FileSystemElement, ScriptBlockElement), SceneMatchError>) -> Void)
}

struct ActionMatchingResult: Codable, Equatable, Hashable {
    let action: ScriptBlockElement
    let matchingSimilarity: Double
}

final class ActionMatcher: ActionMatcherProtocol {
    private struct MatchingResponse: Decodable {
        let file: FileSystemElement
        let phrase: ScriptBlockElement
    }

    func match(file: FileSystemElement, actions: [ScriptBlockElement], projectId: UUID, completion: @escaping (Result<(FileSystemElement, ScriptBlockElement), SceneMatchError>) -> Void) {
        match(files: [file], actions: actions, projectId: projectId, completion: completion)
    }

    func match(files: [FileSystemElement], actions: [ScriptBlockElement], projectId: UUID, completion: @escaping (Result<(FileSystemElement, ScriptBlockElement), SceneMatchError>) -> Void) {
        guard let url = URL(string: "\(EnvironmentVariables.baseUrl)/matchActions") else {
            print(URLError.badURL)
            return
        }
        let body: [String: Any] = [
            "project_id": projectId.uuidString,
            "files": files.map { file in
                let audioClassNames = (file.audioClasses ?? []).map { $0.className }
                let videoClassNames = (file.videoClasses ?? []).map { $0.className }
                let combinedClasses = audioClassNames + videoClassNames
                
                return [
                    "id": file.id.uuidString,
                    "classes": combinedClasses,
                    "tScriptPhraseId": file.tScriptPhraseId?.uuidString ?? "-"
                ]
            }
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                files.forEach { file in
                    completion(.failure(SceneMatchError(fileId: file.id, underlyingError: error ?? URLError(.badServerResponse))))
                }
                return
            }
            do {
//                let responses = try JSONDecoder().decode([MatchPhraseResponse].self, from: data)
//                responses.forEach { response in
//                    guard let f = response.file,
//                    var updatedFile = files.first(where: { $0.id == UUID(uuidString: f.id) }) else { return }
//                    guard let match = response.bestMatch,
//                          let phrase = actions.first(where: { $0.id == UUID(uuidString: match.phraseId) }) else {
//                        completion(.failure(SceneMatchError(fileId: updatedFile.id, underlyingError: URLError(.unknown))))
//                        return
//                    }
//                    updatedFile.sceneId = phrase.id
//                    updatedFile.matchingAccuracy = match.accuracy
//                    var subsArray = [Subtitle]()
//                    f.subtitles?.forEach({ sub in
//                        var subtitle = Subtitle(using: sub)
//                        var matches = [MatchingResult]()
//                        sub.bestMatches.forEach { match in
//                            if let ph = actions.first(where: { $0.id == UUID(uuidString: match.phraseId) }) {
//                                matches.append(ActionMatchingResult(action: ph, matchingCount: match.matchingCount))
//                            }
//                        }
//                        subtitle.bestMatches = matches
//                        subsArray.append(subtitle)
//                    })
//                    updatedFile.subtitles = subsArray
//                    completion(.success((updatedFile, phrase)))
//                }
            } catch {
                files.forEach { file in
                    completion(.failure(SceneMatchError(fileId: file.id, underlyingError: error)))
                }
            }
        }.resume()
    }
}
