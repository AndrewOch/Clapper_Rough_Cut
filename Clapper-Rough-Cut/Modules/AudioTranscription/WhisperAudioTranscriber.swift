import Combine
import WhisperKit
import Foundation

protocol AudioTranscriber {
    func transcribeFiles(_ files: [FileSystemElement]) -> AnyPublisher<FileSystemElement, Never>
    func transcribeFile(_ file: FileSystemElement) -> AnyPublisher<FileSystemElement, Never>
}

class WhisperAudioTranscriber: AudioTranscriber {
    private let queue = DispatchQueue(label: "com.transcription.queue", qos: .userInitiated)
    private var semaphore: DispatchSemaphore
    private var cancellables = Set<AnyCancellable>()

    init() {
        let processorCount = ProcessInfo.processInfo.processorCount
        self.semaphore = DispatchSemaphore(value: processorCount)
    }

    func transcribeFiles(_ files: [FileSystemElement]) -> AnyPublisher<FileSystemElement, Never> {
        let subject = PassthroughSubject<FileSystemElement, Never>()
        let sortedFiles = files.sorted { $0.duration ?? 0 < $1.duration ?? 0 }

        sortedFiles.forEach { file in
            self.transcribeFile(file)
                .sink { processedFile in
                    subject.send(processedFile)
                }
                .store(in: &cancellables)
        }
        return subject
            .handleEvents(receiveCompletion: { _ in subject.send(completion: .finished) })
            .eraseToAnyPublisher()
    }

    func transcribeFile(_ file: FileSystemElement) -> AnyPublisher<FileSystemElement, Never> {
        Future<FileSystemElement, Never> { [weak self] promise in
            guard let self = self else {
                promise(.success(file))
                return
            }
            self.queue.async {
                self.semaphore.wait()
                guard let url = file.url else {
                    self.semaphore.signal()
                    promise(.success(file))
                    return
                }
                let startTime = Date()
                Task {
                    do {
                        let whisper = try await WhisperKit(model: "small")
                        let options = DecodingOptions(language: "ru", wordTimestamps: true)

                        let converter = Converter()
                        converter.convertAudioFileToPCMArray(fileURL: url) { result in
                            switch result {
                            case .success(let audioFrames):
                                Task {
                                    do {
                                        let transcriptionResult: [TranscriptionResult] = try await whisper.transcribe(audioArray: audioFrames, decodeOptions: options)
                                        var modifiedFile: FileSystemElement = file
                                        var subtitles = [Subtitle]()
                                        transcriptionResult.flatMap({ res in res.allWords }).forEach { wordTiming in
                                            subtitles.append(Subtitle(text: wordTiming.word,
                                                                      startTime: Double(wordTiming.start),
                                                                      endTime: Double(wordTiming.end)))
                                        }
                                        modifiedFile.subtitles = subtitles
                                        let endTime = Date()
                                        modifiedFile.transcriptionTime = endTime.timeIntervalSince(startTime)
                                        self.semaphore.signal()
                                        promise(.success(modifiedFile))
                                    } catch {
                                        print("Transcription error: \(error)")
                                        self.semaphore.signal()
                                        promise(.success(file))
                                    }
                                }
                            case .failure(let error):
                                print("Error converting audio file: \(error)")
                                self.semaphore.signal()
                                promise(.success(file))
                            }
                        }
                    } catch {
                        print("Error during transcription: \(error)")
                        self.semaphore.signal()
                        promise(.success(file))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
