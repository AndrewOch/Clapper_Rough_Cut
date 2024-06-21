import Foundation

struct Subtitle: Equatable, Codable, Hashable {
    let text: String
    let startTime: Double
    let endTime: Double
    var phraseId: UUID?
    var matchAccuracy: Double?
    var bestMatches: [MatchingResult]?

    var dictionaryRepresentation: [String: Any] {
        var dict = [String: Any]()
        dict["text"] = text
        dict["start_time"] = startTime
        dict["end_time"] = endTime
        return dict
    }

    init(text: String, startTime: Double, endTime: Double, phraseId: UUID? = nil, matchAccuracy: Double? = nil, bestMatches: [MatchingResult]? = nil) {
        self.text = text
        self.startTime = startTime
        self.endTime = endTime
        self.phraseId = phraseId
        self.matchAccuracy = matchAccuracy
        self.bestMatches = bestMatches
    }

    init(using response: MatchPhraseSubtitleResponse) {
        text = response.text
        startTime = response.startTime
        endTime = response.endTime
        phraseId = UUID(uuidString: response.phraseId)
        matchAccuracy = response.matchAccuracy
    }
}

extension Subtitle {
    var accuracy: Double? {
        bestMatches?.compactMap({ $0.matchAccuracy }).max()
    }
}
