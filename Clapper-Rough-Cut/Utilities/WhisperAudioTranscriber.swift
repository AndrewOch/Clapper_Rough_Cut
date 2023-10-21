import Foundation
import AVFoundation
import Dispatch
import Combine

protocol AudioTranscriber {
    func transcribeFiles(_ files: [FileSystemElement], quality: TranscriptionQuality) -> AnyPublisher<FileSystemElement, Never>
    func transcribeFile(_ file: FileSystemElement, quality: TranscriptionQuality) -> AnyPublisher<FileSystemElement, Never>
}

public enum TranscriptionQuality {
    case low
    case high
}

public struct TranscriptionProgress {
    public let progress: Double
}

class WhisperProgressCapture {
    private var progress: Double = 0
    private var captureProcess: Process?

    func startCapture() {
        let capturePipe = Pipe()
        let captureProcess = Process()
        captureProcess.launchPath = "/bin/sh"
        captureProcess.arguments = ["-c", "whisper_full_with_state"]
        captureProcess.standardOutput = capturePipe
        capturePipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if let output = String(data: data, encoding: .utf8) {
                if let range = output.range(of: "progress = ") {
                    let progressString = output[range.upperBound...].trimmingCharacters(in: .whitespaces)
                    if let progress = Double(progressString) {
                        self.progress = progress
                    }
                }
            }
        }
        captureProcess.launch()
        self.captureProcess = captureProcess
    }

    func stopCapture() {
        captureProcess?.terminate()
        captureProcess?.waitUntilExit()
    }
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
            transcribe(audioFile: audioFile, quality: quality) { result in
                if result.status == .success {
                    if let transcription = result.transcription {
                        var newFile = self.audioFile
                        newFile.transcription = transcription
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
                            completion: @escaping (TranscriptionResult) -> Void) {
        var model: String?
        switch quality {
        case .low:
            model = self.whisperFastModel
        case .high:
            model = self.whisperQualityModel
        }
        guard let model = model, let url = audioFile.url, let duration = audioFile.duration else {
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
                        var numThreads = "4"
                        var numProcesses = "2"
                        if duration > 100 {
                            numThreads = "1"
                            numProcesses = "8"
                        }
                        print("TMP file " + tmpFile)
                        do {
                            var result = try ScriptRunner.safeShell([self.whisperScript,
                                                                     "-t", numThreads,
                                                                     "-p", numProcesses,
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
                                                               transcription: result,
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
