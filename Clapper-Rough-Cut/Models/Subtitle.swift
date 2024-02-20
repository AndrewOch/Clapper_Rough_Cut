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

extension Subtitle {
    static func merge(_ subtitles: [Subtitle]) -> Subtitle {
        let text = subtitles.map { $0.text }.joined(separator: " ")
        let startTime = subtitles.map { $0.startTime }.min() ?? 0
        let endTime = subtitles.map { $0.endTime }.max() ?? 0

        let combinedMatches = subtitles
            .compactMap { $0.bestMatches }
            .flatMap { $0 }
            .reduce(into: [UUID: MatchingResult]()) { (dict, matchingResult) in
                if let existing = dict[matchingResult.phrase.id] {
                    dict[matchingResult.phrase.id] = MatchingResult(
                        phrase: matchingResult.phrase,
                        matchingCount: existing.matchingCount + matchingResult.matchingCount
                    )
                } else {
                    dict[matchingResult.phrase.id] = matchingResult
                }
            }.values
        return Subtitle(
            text: text,
            startTime: startTime,
            endTime: endTime,
            phraseId: nil,
            matchAccuracy: nil,
            bestMatches: Array(combinedMatches)
        )
    }
}

extension Subtitle {
    static func generateMatchedCombinations(of subtitleMatches: [Subtitle: [MatchingResult]]) -> [[Subtitle]] {
        let subtitles = Array(subtitleMatches.keys)
        func recurse(_ subtitles: [Subtitle],
                     index: Int,
                     currentCombination: [Subtitle],
                     allCombinations: inout [[Subtitle]]) {
            if index == subtitles.count {
                allCombinations.append(currentCombination)
                return
            }

            for endIndex in index..<subtitles.count {
                let rangeToMerge = Array(subtitles[index...endIndex])
                var mergedSubtitle = Subtitle.merge(rangeToMerge)
                mergedSubtitle.bestMatches = rangeToMerge
                    .compactMap { subtitleMatches[$0]?.max(by: { $0.matchingCount < $1.matchingCount }) }
                recurse(subtitles, index: endIndex + 1, currentCombination: currentCombination + [mergedSubtitle], allCombinations: &allCombinations)
            }
            if index > 0 {
                var currentSubtitle = subtitles[index]
                currentSubtitle.bestMatches = subtitleMatches[currentSubtitle]?
                    .sorted(by: { $0.matchingCount < $1.matchingCount })
                recurse(subtitles, index: index + 1, currentCombination: currentCombination + [currentSubtitle], allCombinations: &allCombinations)
            }
        }

        var allCombinations = [[Subtitle]]()
        recurse(subtitles, index: 0, currentCombination: [], allCombinations: &allCombinations)

        return allCombinations.map { combination in
            combination.map { subtitle in
                var newSubtitle = subtitle
                newSubtitle.bestMatches = newSubtitle.bestMatches?
                    .sorted(by: { $0.matchingCount > $1.matchingCount })
                    .prefix(5)
                    .map { $0 }
                return newSubtitle
            }
        }
    }
}

extension Subtitle {
    static func generateCombinations(of subtitles: [Subtitle]) -> [[Subtitle]] {
        guard !subtitles.isEmpty else { return [[]] }
        func recurse(_ subtitles: [Subtitle], index: Int, currentCombination: [Subtitle], allCombinations: inout [[Subtitle]]) {
            if index == subtitles.count {
                allCombinations.append(currentCombination)
                return
            }
            for endIndex in index..<subtitles.count {
                let rangeToMerge = Array(subtitles[index...endIndex])
                let mergedSubtitle = Subtitle.merge(rangeToMerge)
                recurse(subtitles, index: endIndex + 1, currentCombination: currentCombination + [mergedSubtitle], allCombinations: &allCombinations)
            }
            if index > 0 {
                recurse(subtitles, index: index + 1, currentCombination: currentCombination + [subtitles[index]], allCombinations: &allCombinations)
            }
        }
        var allCombinations = [[Subtitle]]()
        recurse(subtitles, index: 0, currentCombination: [], allCombinations: &allCombinations)
        return allCombinations
    }
}
