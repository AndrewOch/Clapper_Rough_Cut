import Foundation

struct BestPhraseMatchResponse: Codable {
    let phraseId: String
    let accuracy: Double

    enum CodingKeys: String, CodingKey {
        case phraseId = "phrase_id"
        case accuracy = "accuracy"
    }
}

struct BestPhraseMatchDetailResponse: Codable {
    let phraseId: String
    let matchingCount: Int

    enum CodingKeys: String, CodingKey {
        case phraseId = "phrase_id"
        case matchingCount = "matching_count"
    }
}

struct MatchPhraseSubtitleResponse: Codable {
    let text: String
    let startTime: Double
    let endTime: Double
    let phraseId: String
    let matchAccuracy: Double
    let bestMatches: [BestPhraseMatchDetailResponse]

    enum CodingKeys: String, CodingKey {
        case text
        case startTime = "start_time"
        case endTime = "end_time"
        case phraseId = "phrase_id"
        case matchAccuracy = "match_accuracy"
        case bestMatches = "best_matches"
    }
}

struct MatchPhraseFileResponse: Codable {
    let subtitles: [MatchPhraseSubtitleResponse]?
    let id: String

    enum CodingKeys: String, CodingKey {
        case subtitles
        case id
    }
}

struct MatchPhraseResponse: Codable {
    let file: MatchPhraseFileResponse?
    let bestMatch: BestPhraseMatchResponse?

    enum CodingKeys: String, CodingKey {
        case file
        case bestMatch = "best_match"
    }
}
