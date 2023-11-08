import Foundation
import NaturalLanguage

protocol PhraseMatcherProtocol {
    func match(files: [FileSystemElement], phrases: [Phrase], completion: @escaping (FileSystemElement, Phrase) -> Void)
    func match(file: FileSystemElement, phrases: [Phrase], completion: @escaping (FileSystemElement, Phrase) -> Void)
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
    public func match(files: [FileSystemElement],
                      phrases: [Phrase],
                      completion: @escaping (FileSystemElement, Phrase) -> Void) {
        let startTime = Date().timeIntervalSince1970
        let textsMatcherWrapper = TextsMatcher_Wrapper()
        for file in files {
            matchFile(file: file, phrases: phrases, matcher: textsMatcherWrapper) { element, phrase in
                completion(element, phrase)
            }
        }
        let endTime = Date().timeIntervalSince1970
        let elapsed = endTime - startTime
        print("Total sorting time: \(elapsed) seconds")
    }

    public func match(file: FileSystemElement,
                      phrases: [Phrase],
                      completion: @escaping (FileSystemElement, Phrase) -> Void) {
        let startTime = Date().timeIntervalSince1970
        let textsMatcherWrapper = TextsMatcher_Wrapper()
        matchFile(file: file, phrases: phrases, matcher: textsMatcherWrapper) { element, phrase in
            completion(element, phrase)
        }
        let endTime = Date().timeIntervalSince1970
        let elapsed = endTime - startTime
        print("Sorting time: \(elapsed) seconds")
    }

    private func matchFile(file: FileSystemElement,
                           phrases: [Phrase],
                           matcher: TextsMatcher_Wrapper,
                           completion: @escaping (FileSystemElement, Phrase) -> Void) {
        guard let subtitles = file.subtitles else { return }

        var res: [Subtitle: [MatchingResult]] = [:]
        var cleanedPhrases: [Phrase: String] = [:]
        for phrase in phrases {
            guard let phraseText = phrase.phraseText else { continue }
            let cleanedPhrase = removeEnclosedText(phraseText).trimmingCharacters(in: .whitespaces)
            if cleanedPhrase.components(separatedBy: .whitespaces).isEmpty { continue }
            cleanedPhrases[phrase] = cleanedPhrase
        }
        for subtitle in subtitles {
            var results = [MatchingResult]()
            for phrase in cleanedPhrases {
                let length = matcher.matchingSequenceLength(text1: subtitle.text.lowercased(),
                                                            text2: phrase.value.lowercased())
                if length == 0 { continue }
                results.append(MatchingResult(phrase: phrase.key, matchingCount: length))
            }
            res[subtitle] = results
        }
        let combinations = Subtitle.generateMatchedCombinations(of: res)
        guard let bestMatch = getBestCombination(combinations: combinations,
                                                 phrases: phrases,
                                                 matcher: matcher) else {
            print("Best match does not found")
            return
        }
        var file = file
        file.subtitles = bestMatch.0
//        print(file.subtitles)
        print(file.subtitles?.compactMap({ $0.matchAccuracy }).max())
        completion(file, bestMatch.1)
    }

    private func getBestMatch(phrasesMap: [([Int], Phrase)]) -> ([Int], Phrase)? {
        var phrasesMap = phrasesMap.map { (key: $0.sorted(by: >), value: $1) }
        while phrasesMap.count > 1 {
            let maxInt = phrasesMap.flatMap { $0.0 }.max() ?? 0
            phrasesMap = phrasesMap.filter { $0.key.first == maxInt }
            var newPhrasesMap = [(key: [Int], value: Phrase)]()
            for (key, value) in phrasesMap {
                if key.count >= 2 {
                    let newKey = Array(key.dropFirst())
                    newPhrasesMap.append((key: newKey, value: value))
                } else {
                    newPhrasesMap.append((key: key, value: value))
                }
            }
            phrasesMap = newPhrasesMap
            if phrasesMap.count > 1 && phrasesMap.allSatisfy({ $0.0.count == 1 }) {
                print()
                for phrase in phrasesMap {
                    print("Conflicting: ", phrase.key, phrase.value.fullText)
                }
                print()
                return phrasesMap.first
            }
        }
        return phrasesMap.first
    }

    private func getBestCombination(combinations: [[Subtitle]],
                                    phrases: [Phrase],
                                    matcher: TextsMatcher_Wrapper) -> ([Subtitle], Phrase)? {
        var bestAccuracy: Double = 0
        var bestCombination: [Subtitle] = []
        var bestPhrase: Phrase?

        // Поиск лучшей комбинации и соответствующей фразы
        for combination in combinations {
            let accuracies = combination.compactMap { $0.bestMatches?.first?.matchAccuracy }
            if let maxAccuracy = accuracies.max(), maxAccuracy > bestAccuracy {
                bestAccuracy = maxAccuracy
                bestCombination = combination
                // Находим фразу с максимальной точностью
                if let index = accuracies.firstIndex(of: maxAccuracy),
                   let phraseId = combination[index].bestMatches?.first?.phrase.id {
                    bestPhrase = phrases.first { $0.id == phraseId }
                }
            }
        }

        // Проверяем, есть ли лучшая фраза
        guard let phrase = bestPhrase, let phraseText = phrase.phraseText else { return nil }

        // Очищаем фразу и проверяем, что она не пуста
        let cleanedPhrase = removeEnclosedText(phraseText).trimmingCharacters(in: .whitespaces)
        if cleanedPhrase.components(separatedBy: .whitespaces).isEmpty { return nil }

        // Обновляем соответствия для лучшей комбинации
        for i in bestCombination.indices {
            let length = matcher.matchingSequenceLength(text1: bestCombination[i].text.lowercased(),
                                                        text2: cleanedPhrase.lowercased())
            let matchingResult = MatchingResult(phrase: phrase, matchingCount: length)
            bestCombination[i].bestMatches?.append(matchingResult)
            bestCombination[i].phraseId = phrase.id
            bestCombination[i].matchAccuracy = matchingResult.matchAccuracy
        }

        return (bestCombination, phrase)
    }

    private func countMatchingWords(text1: String, text2: String) -> Int {
        let words1 = text1.components(separatedBy: .whitespaces)
        let words2 = text2.components(separatedBy: .whitespaces)
        var matchCount = 0
        var lastIndex = 0

        DispatchQueue.concurrentPerform(iterations: words1.count) { i in
            let word1 = words1[i]
            if word1.isEmpty { return }
            guard words2.count > lastIndex else { return }
            for (index, word2) in words2[lastIndex...].enumerated() {
                let j = lastIndex + index
                if word2.isEmpty { continue }
                let distance = StringsMatcher_Wrapper().distance(word1, word2)
                if distance < word2.count / 4 {
                    matchCount += 1
                    lastIndex = j + 1
                    break
                }
            }
        }
        return matchCount
    }

    private func matchingSequenceLength(text1: String, text2: String) -> Int {
        let words1 = text1.components(separatedBy: .whitespaces)
        let words2 = text2.components(separatedBy: .whitespaces)
        var maxSequenceLength = 0
        var currentSequenceLength = 0
        var matchCount = 0
        var lastIndex = 0

        DispatchQueue.concurrentPerform(iterations: words1.count) { i in
            let word1 = words1[i]
            if word1.isEmpty { return }
            guard words2.count > lastIndex else { return }
            for (index, word2) in words2[lastIndex...].enumerated() {
                let j = lastIndex + index
                if word2.isEmpty { continue }
                let diff = abs(word1.count - word2.count)
                if word1.count / 2 <= diff || word2.count / 2 <= diff {
                    if maxSequenceLength < currentSequenceLength {
                        maxSequenceLength = currentSequenceLength
                    }
                    currentSequenceLength = 0
                    continue
                }
                let distance = StringsMatcher_Wrapper().distance(word1, word2)
                if distance < word2.count / 4 {
                    matchCount += 1
                    currentSequenceLength += 1
                    lastIndex = j + 1
                    break
                } else {
                    if maxSequenceLength < currentSequenceLength {
                        maxSequenceLength = currentSequenceLength
                    }
                    currentSequenceLength = 0
                }
            }
        }
        if maxSequenceLength < currentSequenceLength {
            maxSequenceLength = currentSequenceLength
        }
        return maxSequenceLength
    }

    private func matchingRatio(text1: String, text2: String) -> Double {
        let words1 = text1.components(separatedBy: .whitespaces)
        let words2 = text2.components(separatedBy: .whitespaces)
        var maxSequenceLength = 0
        var currentSequenceLength = 0
        var matchCount = 0
        var lastIndex = 0

        DispatchQueue.concurrentPerform(iterations: words1.count) { i in
            let word1 = words1[i]
            if word1.isEmpty { return }
            guard words2.count > lastIndex else { return }
            for (index, word2) in words2[lastIndex...].enumerated() {
                let j = lastIndex + index
                if word2.isEmpty { continue }
                let diff = abs(word1.count - word2.count)
                if word1.count / 2 <= diff || word2.count / 2 <= diff {
                    if maxSequenceLength < currentSequenceLength {
                        maxSequenceLength = currentSequenceLength
                    }
                    currentSequenceLength = 0
                    continue
                }
                let distance = StringsMatcher_Wrapper().distance(word1, word2)
                if distance < word2.count / 4 {
                    matchCount += 1
                    currentSequenceLength += 1
                    lastIndex = j + 1
                    break
                } else {
                    if maxSequenceLength < currentSequenceLength {
                        maxSequenceLength = currentSequenceLength
                    }
                    currentSequenceLength = 0
                }
            }
        }
        if maxSequenceLength < currentSequenceLength {
            maxSequenceLength = currentSequenceLength
        }
        if matchCount == 0 { return 0 }
        return Double(maxSequenceLength / matchCount)
    }

    private func distance(text1: String, text2: String) -> Int {
        return StringsMatcher_Wrapper().distance(text1, text2)
    }

    private func removeEnclosedText(_ text: String) -> String {
        var result = text
        result = result.replacingOccurrences(of: #"\[.*?\]"#, with: "", options: .regularExpression)
        result = result.replacingOccurrences(of: #"\(.*?\)"#, with: "", options: .regularExpression)
        result = result.replacingOccurrences(of: #"<.*?>"#, with: "", options: .regularExpression)
        result = result.replacingOccurrences(of: #"\*.*?\*"#, with: "", options: .regularExpression)
        return result
    }
}
