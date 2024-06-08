import SoundAnalysis
import AVFoundation
import Combine

protocol AudioClassificatorProtocol {
    func classifyAudio(file: FileSystemElement) -> AnyPublisher<FileSystemElement, Never>
    func classifyAudios(files: [FileSystemElement]) -> AnyPublisher<FileSystemElement, Never>
}

class AudioClassificator: AudioClassificatorProtocol {
    private let queue = DispatchQueue(label: "com.audio_classification.queue", qos: .userInitiated)
    private var semaphore: DispatchSemaphore
    private var cancellables = Set<AnyCancellable>()

    init() {
        let processorCount = ProcessInfo.processInfo.processorCount / 2 + 1
        self.semaphore = DispatchSemaphore(value: processorCount)
    }

    func classifyAudio(file: FileSystemElement) -> AnyPublisher<FileSystemElement, Never> {
        Future<FileSystemElement, Never> { [weak self] promise in
            guard let self = self else {
                promise(.success(file))
                return
            }
            self.queue.async {
                self.semaphore.wait()
                guard let url = file.url else {
                    print("URL аудиофайла отсутствует")
                    self.semaphore.signal()
                    promise(.success(file))
                    return
                }
                do {
                    let audioFileAnalyzer = try SNAudioFileAnalyzer(url: url)
                    let classifySoundRequest = self.createSoundClassificationRequest()

                    let resultsObserver = ResultsObserver(file: file) { classifiedFile in
                        self.semaphore.signal()
                        promise(.success(classifiedFile))
                    }

                    try audioFileAnalyzer.add(classifySoundRequest, withObserver: resultsObserver)
                    audioFileAnalyzer.analyze()
                } catch {
                    print("Ошибка при анализе аудиофайла: \(error.localizedDescription)")
                    self.semaphore.signal()
                    promise(.success(file))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func classifyAudios(files: [FileSystemElement]) -> AnyPublisher<FileSystemElement, Never> {
        let subject = PassthroughSubject<FileSystemElement, Never>()
        let sortedFiles = files.sorted { $0.duration ?? 0 < $1.duration ?? 0 }

        sortedFiles.forEach { file in
            self.classifyAudio(file: file)
                .sink { processedFile in
                    subject.send(processedFile)
                }
                .store(in: &cancellables)
        }
        
        return subject
            .handleEvents(receiveCompletion: { _ in subject.send(completion: .finished) })
            .eraseToAnyPublisher()
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
        self.completion(self.file) // завершение с ошибкой
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
