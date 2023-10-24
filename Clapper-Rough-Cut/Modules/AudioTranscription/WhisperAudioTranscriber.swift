import Foundation
import AVFoundation
import Dispatch
import Combine

protocol AudioTranscriber {
    func transcribeFiles(_ files: [FileSystemElement], quality: TranscriptionQuality) -> AnyPublisher<FileSystemElement, Never>
    func transcribeFile(_ file: FileSystemElement, quality: TranscriptionQuality) -> AnyPublisher<FileSystemElement, Never>
}

class TranscriptionPublisher: Publisher {
    typealias Output = FileSystemElement
    typealias Failure = Never

    private let audioFile: FileSystemElement
    private let quality: TranscriptionQuality

    init(audioFile: FileSystemElement, quality: TranscriptionQuality) {
        self.audioFile = audioFile
        self.quality = quality
    }

    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = TranscriptionSubscription(subscriber: subscriber, audioFile: audioFile, quality: quality)
        subscriber.receive(subscription: subscription)
    }
}

class TranscriptionSubscription<S: Subscriber>: Subscription where S.Input == FileSystemElement {
    private let converter = Converter()
    private var subscriber: S?
    private let audioFile: FileSystemElement
    private let quality: TranscriptionQuality

    init(subscriber: S, audioFile: FileSystemElement, quality: TranscriptionQuality) {
            self.subscriber = subscriber
            self.audioFile = audioFile
            self.quality = quality
        }

    func request(_ demand: Subscribers.Demand) {
        transcribe(audioFile: audioFile, quality: quality) { progress in
            self.subscriber?.receive(self.audioFile)
        } completion: { result in
            if result.status == .success {
                if let transcription = result.transcription {
                    var newFile = self.audioFile
                    newFile.subtitles = transcription
                    self.subscriber?.receive(newFile)
                }
            }
            self.subscriber?.receive(completion: .finished)
            self.subscriber = nil
        }
    }

    func cancel() {
        subscriber = nil
    }

    private var whisperScript: String {
        guard let path = Bundle.main.path(forResource: "main", ofType: "") else {
            print("File not found")
            return ""
        }
        return path
    }

    private var whisperFastModel: String {
        guard let path = Bundle.main.path(forResource: "ggml-base", ofType: ".bin") else {
            print("File for fast model not found")
            return ""
        }
        return path
    }

    private var whisperQualityModel: String {
        guard let path = Bundle.main.path(forResource: "ggml-medium", ofType: ".bin") else {
            print("File for quality model not found")
            return ""
        }
        return path
    }

    private func transcribe(audioFile: FileSystemElement,
                            quality: TranscriptionQuality = .low,
                            progress: @escaping (Double) -> Void,
                            completion: @escaping (TranscriptionResult) -> Void) {
        var model: String?
        switch quality {
        case .low:
            model = self.whisperFastModel
        case .high:
            model = self.whisperQualityModel
        }
        guard let model = model, let url = audioFile.url else {
            completion(TranscriptionResult(status: .failure,
                                           transcription: nil,
                                           transcriptionDuration: nil))
            return
        }
        let startTime = Date().timeIntervalSince1970
        DispatchQueue.global().async {
            self.converter.convertAudioFile(url) { result in
                switch result {
                case .success(let outputURL):
                    let tmpFile = outputURL.path
                    if FileManager.default.fileExists(atPath: tmpFile) {
                        let maxThreads = max(1, min(8, ProcessInfo.processInfo.processorCount - 2))
                        do {
                            var result = try ScriptRunner.safeShell([self.whisperScript,
                                                                     "-t", String(maxThreads),
                                                                     "-l", "ru",
                                                                     "-m", model,
                                                                     "-pp", tmpFile])
                            result = result.trimmingCharacters(in: .whitespacesAndNewlines)
                            let endTime = Date().timeIntervalSince1970
                            let resultTime = endTime - startTime
                            do {
                                try FileManager.default.removeItem(at: outputURL)
                            } catch {
                                print("Failed to delete temporary file: \(error)")
                            }
                            DispatchQueue.main.async {
                                completion(TranscriptionResult(status: .success,
                                                               transcription: self.parseSubtitles(from: result, duration: audioFile.duration ?? 0),
                                                               transcriptionDuration: resultTime))
                            }
                        } catch {
                            do {
                                try FileManager.default.removeItem(at: outputURL)
                            } catch {
                                print("Failed to delete temporary file: \(error)")
                            }
                            print("Transcription failed with error: \(error.localizedDescription)")
                            DispatchQueue.main.async {
                                completion(TranscriptionResult(status: .failure,
                                                               transcription: nil,
                                                               transcriptionDuration: nil))
                            }
                        }
                    }
                case .failure(let error):
                    print("Conversion failed with error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(TranscriptionResult(status: .failure,
                                                       transcription: nil,
                                                       transcriptionDuration: nil))
                    }
                }
            }
        }
    }

    private func parseSubtitles(from text: String, duration: Double) -> [Subtitle] {
        let pattern = "\\[(\\d{2}):(\\d{2}):(\\d{2})\\.(\\d{3}) --> (\\d{2}):(\\d{2}):(\\d{2})\\.(\\d{3})\\] (.+)"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
            var subtitles: [Subtitle] = []
            for match in matches {
                let startHours = (text as NSString).substring(with: match.range(at: 1))
                let startMinutes = (text as NSString).substring(with: match.range(at: 2))
                let startSeconds = (text as NSString).substring(with: match.range(at: 3))
                let startMilliseconds = (text as NSString).substring(with: match.range(at: 4))

                let endHours = (text as NSString).substring(with: match.range(at: 5))
                let endMinutes = (text as NSString).substring(with: match.range(at: 6))
                let endSeconds = (text as NSString).substring(with: match.range(at: 7))
                let endMilliseconds = (text as NSString).substring(with: match.range(at: 8))

                let startTime = min(Double(startHours)! * 3_600 + Double(startMinutes)! * 60 + Double(startSeconds)! + Double(startMilliseconds)! / 1_000.0 + 2, duration)
                let endTime = min(Double(endHours)! * 3_600 + Double(endMinutes)! * 60 + Double(endSeconds)! + Double(endMilliseconds)! / 1_000.0 + 2, duration)

                let subtitleText = (text as NSString).substring(with: match.range(at: 9))
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                let subtitle = Subtitle(text: subtitleText, startTime: startTime, endTime: endTime)
                subtitles.append(subtitle)
            }
            return subtitles
        } catch {
            print("Error parsing subtitles: \(error)")
            return []
        }
    }
}

class WhisperAudioTranscriber: AudioTranscriber {
    func transcribeFiles(_ files: [FileSystemElement], quality: TranscriptionQuality = .low) -> AnyPublisher<FileSystemElement, Never> {
        let publishers = files.map { file in
            TranscriptionPublisher(audioFile: file, quality: quality)
                .eraseToAnyPublisher()
        }
        return Publishers.MergeMany(publishers)
            .eraseToAnyPublisher()
    }

    func transcribeFile(_ file: FileSystemElement, quality: TranscriptionQuality = .low) -> AnyPublisher<FileSystemElement, Never> {
        return TranscriptionPublisher(audioFile: file, quality: quality)
            .eraseToAnyPublisher()
    }
}
