import Combine
import WhisperKit
import Foundation

protocol AudioTranscriber {
    func transcribeFiles(_ files: [FileSystemElement]) -> AnyPublisher<FileSystemElement, Never>
    func transcribeFile(_ file: FileSystemElement) -> AnyPublisher<FileSystemElement, Never>
}

class WhisperAudioTranscriber: AudioTranscriber {

    func transcribeFiles(_ files: [FileSystemElement]) -> AnyPublisher<FileSystemElement, Never> {
        let publishers = files.map { self.transcribeFile($0) }
        return Publishers.MergeMany(publishers).eraseToAnyPublisher()
    }

    func transcribeFile(_ file: FileSystemElement) -> AnyPublisher<FileSystemElement, Never> {
        Future<FileSystemElement, Never> { promise in
            guard let url = file.url else {
                promise(.success(file))
                return
            }
            Task {
                do {
                    let seeker = SegmentSeeker()
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
                                    
                                    
                                    print(transcriptionResult.map({ res in res.allWords }))
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
                } catch {
                    print("Error during transcription: \(error)")
                    promise(.success(file))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
