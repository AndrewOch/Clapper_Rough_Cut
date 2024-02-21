import Foundation
import NaturalLanguage

protocol PhraseMatcherProtocol {
    func match(files: [FileSystemElement], phrases: [Phrase], projectId: UUID, completion: @escaping (Result<(FileSystemElement, Phrase), Error>) -> Void)
    func match(file: FileSystemElement, phrases: [Phrase], projectId: UUID, completion: @escaping (Result<(FileSystemElement, Phrase), Error>) -> Void)
}

struct MatchingResult: Codable, Equatable, Hashable {
    let phrase: Phrase
    let matchingCount: Int

    var matchAccuracy: Double {
        guard let count = phrase.phraseText?.components(separatedBy: .whitespaces).count else { return 0 }
        return Double(matchingCount) / Double(count)
    }
}

final class PhraseMatcher: PhraseMatcherProtocol {
    private struct MatchingResponse: Decodable {
        let file: FileSystemElement
        let phrase: Phrase
    }

    func match(file: FileSystemElement, phrases: [Phrase], projectId: UUID, completion: @escaping (Result<(FileSystemElement, Phrase), Error>) -> Void) {
         match(files: [file], phrases: phrases, projectId: projectId, completion: completion)
    }

    func match(files: [FileSystemElement], phrases: [Phrase], projectId: UUID, completion: @escaping (Result<(FileSystemElement, Phrase), Error>) -> Void) {
        guard let url = URL(string: "\(EnvironmentVariables.baseUrl)/matchScenes") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        let body: [String: Any] = [
            "project_id": projectId.uuidString,
            "files": files.map { file in [
                "id": file.id.uuidString,
                "subtitles": ((file.subtitles ?? []) as [Subtitle]).map { $0.dictionaryRepresentation }
            ] }
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? URLError(.badServerResponse)))
                return
            }
            do {
                let responses = try JSONDecoder().decode([MatchPhraseResponse].self, from: data)
                responses.forEach { response in
                    guard let f = response.file,
                          let match = response.bestMatch,
                          let phrase = phrases.first(where: { $0.id == UUID(uuidString: match.phraseId) }),
                          var updatedFile = files.first(where: { $0.id == UUID(uuidString: f.id) }) else { return }
                    updatedFile.scriptPhraseId = phrase.id
                    var subsArray = [Subtitle]()
                    f.subtitles?.forEach({ sub in
                        var subtitle = Subtitle(using: sub)
                        var matches = [MatchingResult]()
                        sub.bestMatches.forEach { match in
                            if let ph = phrases.first(where: { $0.id == UUID(uuidString: match.phraseId )}) {
                                matches.append(MatchingResult(phrase: ph, matchingCount: match.matchingCount))
                            }
                        }
                        subtitle.bestMatches = matches
                        subsArray.append(subtitle)
                    })
                    updatedFile.subtitles = subsArray
                    completion(.success((updatedFile, phrase)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
