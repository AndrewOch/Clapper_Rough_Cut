import SoundAnalysis
import AVFoundation

protocol AudioClassificatorProtocol {
    func classifyAudio(file: FileSystemElement, completion: @escaping (FileSystemElement) -> Void)
    func classifyAudios(files: [FileSystemElement], completion: @escaping ([FileSystemElement]) -> Void)
}

class AudioClassificator: AudioClassificatorProtocol {
    func classifyAudio(file: FileSystemElement, completion: @escaping (FileSystemElement) -> Void) {
        guard let url = file.url else {
            print("URL аудиофайла отсутствует")
            completion(file)
            return
        }
        do {
            let audioFileAnalyzer = try SNAudioFileAnalyzer(url: url)
            let classifySoundRequest = createSoundClassificationRequest()

            let resultsObserver = ResultsObserver(file: file) { classifiedFile in
                completion(classifiedFile)
            }

            try audioFileAnalyzer.add(classifySoundRequest, withObserver: resultsObserver)
            audioFileAnalyzer.analyze()

        } catch {
            print("Ошибка при анализе аудиофайла: \(error)")
            completion(file)
        }
    }

    func classifyAudios(files: [FileSystemElement], completion: @escaping ([FileSystemElement]) -> Void) {
        let group = DispatchGroup()
        var classifiedFiles = [FileSystemElement]()

        for file in files {
            group.enter()
            classifyAudio(file: file) { classifiedFile in
                classifiedFiles.append(classifiedFile)
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion(classifiedFiles)
        }
    }

    func createSoundClassificationRequest() -> SNClassifySoundRequest {
        let version = SNClassifierIdentifier.version1
        do {
            let request = try SNClassifySoundRequest(classifierIdentifier: version)
            return request
        } catch {
            fatalError("Ошибка при создании запроса на классификацию звука: \(error)")
        }
    }
}

class ResultsObserver: NSObject, SNResultsObserving {
    var completion: (FileSystemElement) -> Void
    var file: FileSystemElement
    private var classificationResults = [String: Float]()
    private let confidenceThreshold: Float = 0.3
    private var resultsCount: Int = 0

    init(file: FileSystemElement, completion: @escaping (FileSystemElement) -> Void) {
        self.file = file
        self.completion = completion
    }

    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult else { return }
        resultsCount += 1
        for classification in result.classifications {
            let confidence = Float(classification.confidence)
            if classificationResults[classification.identifier] != nil {
                classificationResults[classification.identifier]? += confidence
            } else {
                classificationResults[classification.identifier] = confidence
            }
        }
    }

    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("Ошибка классификации: \(error.localizedDescription)")
    }

    func requestDidComplete(_ request: SNRequest) {
        let filteredResults = classificationResults.mapValues { confidence -> Float in
            return confidence / Float(resultsCount)
        }.filter { $0.value >= confidenceThreshold }

        let classifiedElements = filteredResults.map { ClassificationElement(className: $0.key, confidence: $0.value) }
        file.audioClasses = classifiedElements
        completion(file)
    }
}
