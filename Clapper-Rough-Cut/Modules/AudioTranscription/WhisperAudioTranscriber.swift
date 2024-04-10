import Foundation
import AVFoundation
import Dispatch
import Combine
import SwiftWhisper

protocol AudioTranscriber {
    func transcribeFiles(_ files: [FileSystemElement], quality: TranscriptionQuality) -> AnyPublisher<FileSystemElement, Never>
    func transcribeFile(_ file: FileSystemElement, quality: TranscriptionQuality) -> AnyPublisher<FileSystemElement, Never>
}

class WhisperAudioTranscriber: AudioTranscriber {
    func transcribeFiles(_ files: [FileSystemElement], quality: TranscriptionQuality = .low) -> AnyPublisher<FileSystemElement, Never> {
        let publishers = files.map { self.transcribeFile($0, quality: quality) }
        return Publishers.MergeMany(publishers).eraseToAnyPublisher()
    }

    func transcribeFile(_ file: FileSystemElement, quality: TranscriptionQuality = .low) -> AnyPublisher<FileSystemElement, Never> {
        Future<FileSystemElement, Never> { promise in
            Task {
                let modelURL = Bundle.main.url(forResource: "ggml-small", withExtension: "bin")!
                var params = WhisperParams.default
                params.language = .russian
                let whisper = Whisper(fromFileURL: modelURL, withParams: params)
                let converter = Converter()
                converter.convertAudioFileToPCMArray(fileURL: file.url!) { result in
                    switch result {
                    case .success(let audioFrames):
                        Task {
                            do {
                                let segments = try await whisper.transcribe(audioFrames: audioFrames)
                                var modifiedFile = file
                                modifiedFile.subtitles = segments.map { segment in
                                    Subtitle(text: segment.text,
                                             startTime: Double(segment.startTime) / 1000.0,
                                             endTime: Double(segment.endTime) / 1000.0)
                                }
                                promise(.success(modifiedFile))
                            } catch {
                                print("Transcription error: \(error)")
                                promise(.success(file))
                            }
                        }
                    case .failure(let error):
                        print("Error converting audio file: \(error)")
                        promise(.success(file))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
