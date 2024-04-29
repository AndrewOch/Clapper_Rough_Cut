import Foundation
import AVFoundation
import Dispatch
import Combine
import SwiftWhisper

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


//import Combine
//import Speech
//
//class WhisperAudioTranscriber: AudioTranscriber {
//    private var speechRecognizer: SFSpeechRecognizer?
//    private var recognitionTasks = [UUID: PassthroughSubject<FileSystemElement, Never>]()
//
//    init(locale: Locale = Locale(identifier: "ru-RU")) {
//        speechRecognizer = SFSpeechRecognizer(locale: locale)
//        SFSpeechRecognizer.requestAuthorization { status in
//            if status != .authorized {
//                print("Speech recognition authorization denied")
//            }
//        }
//    }
//
//    func transcribeFiles(_ files: [FileSystemElement]) -> AnyPublisher<FileSystemElement, Never> {
//        let publishers = files.map { transcribeFile($0) }
//        return Publishers.MergeMany(publishers).eraseToAnyPublisher()
//    }
//
//    func transcribeFile(_ file: FileSystemElement) -> AnyPublisher<FileSystemElement, Never> {
//        guard let url = file.url, file.type == .audio else {
//            return Just(file).eraseToAnyPublisher()
//        }
//
//        let request = SFSpeechURLRecognitionRequest(url: url)
//        let subject = PassthroughSubject<FileSystemElement, Never>()
//        recognitionTasks[file.id] = subject
//
//        speechRecognizer?.recognitionTask(with: request, delegate: SpeechRecognitionDelegate(file: file, subject: subject, completionHandler: { [weak self] in
//            self?.recognitionTasks.removeValue(forKey: file.id)
//        }))
//        
//        return subject.eraseToAnyPublisher()
//    }
//
//    private class SpeechRecognitionDelegate: NSObject, SFSpeechRecognitionTaskDelegate {
//        var file: FileSystemElement
//        var subject: PassthroughSubject<FileSystemElement, Never>
//        var completionHandler: () -> Void
//
//        init(file: FileSystemElement, subject: PassthroughSubject<FileSystemElement, Never>, completionHandler: @escaping () -> Void) {
//            self.file = file
//            self.subject = subject
//            self.completionHandler = completionHandler
//        }
//
//        func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
//            if successfully {
//                subject.send(file)
//            } else {
//                var newFile = file
//                subject.send(newFile)
//            }
//            subject.send(completion: .finished)
//            completionHandler()
//        }
//
//        func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
//            var newFile = file
//            newFile.subtitles = transcription.segments.map { segment in
//                Subtitle(
//                    text: segment.substring,
//                    startTime: segment.timestamp,
//                    endTime: segment.timestamp + segment.duration
//                )
//            }
//            subject.send(newFile)
//        }
//    }
//}
