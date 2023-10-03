import Foundation
import SwiftWhisper
import AVFoundation
import Dispatch

protocol AudioTranscriber {
    func transcribeFiles(_ files: [RawFile], level: TranscriptionQuality, completion: @escaping (URL, String?) -> Void)
    func transcribeFile(_ file: RawFile, level: TranscriptionQuality, completion: @escaping (String?) -> Void)
}

public enum TranscriptionQuality {
    case low
    case medium
}

class WhisperAudioTranscriber: AudioTranscriber {
    let converter = Converter()

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

    private var whisperQualityModel: Whisper? {
        guard let path = Bundle.main.path(forResource: "ggml-medium", ofType: ".bin") else {
            print("File for fast model not found")
            return nil
        }
        var params = WhisperParams.default
        params.detect_language = true
        let whisper = Whisper(fromFileURL: URL(fileURLWithPath: path), withParams: params)
        return whisper
    }

    private func transcribe(audioFile: RawFile,
                            level: TranscriptionQuality = .low,
                            completion: @escaping (TranscriptionResult) -> Void) {
        guard let model = self.whisperQualityModel else {
            completion(TranscriptionResult(status: .failure,
                                           transcription: nil,
                                           transcriptionDuration: nil))
            return
        }
        let startTime = Date().timeIntervalSince1970
        converter.convertAudioFileToPCMArray(fileURL: audioFile.url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let frames):
                model.transcribe(audioFrames: frames) { result in
                    switch(result) {
                    case .success(let segments):
                        print("Transcribed audio:", segments.map(\.text).joined())
                        let endTime = Date().timeIntervalSince1970
                        let resultTime = endTime - startTime
                        completion(TranscriptionResult(status: .success,
                                                       transcription: segments.map(\.text).joined(),
                                                       transcriptionDuration: resultTime))
                    case .failure(let error):
                        print("Transcription failed with error: \(error.localizedDescription)")
                        completion(TranscriptionResult(status: .failure,
                                                       transcription: nil,
                                                       transcriptionDuration: nil))
                    }
                }
            case .failure(let error):
                print("Conversion failed with error: \(error.localizedDescription)")
                completion(TranscriptionResult(status: .failure,
                                               transcription: nil,
                                               transcriptionDuration: nil))
            }
        }
    }

    func transcribeFiles(_ files: [RawFile], level: TranscriptionQuality = .low, completion: @escaping (URL, String?) -> Void) {
        let totalStartTime = Date().timeIntervalSince1970
        var totalDuration: Double = 0
        var processedCount = 0
        let backgroundQueue = DispatchQueue.global(qos: .background)
        for file in files {
            backgroundQueue.async {
                self.transcribe(audioFile: file, level: level) { result in
                    if (result.status == .success) {
                        if let transcription = result.transcription,
                           let transcriptionDuration = result.transcriptionDuration {
                            print(file.url.lastPathComponent)
                            print(transcription)
                            print("Audio file duration: \(String(format: "%.2f", file.duration)) seconds")
                            print("Transcription time: \(String(format: "%.2f", transcriptionDuration)) seconds")
                            totalDuration += file.duration
                            completion(file.url, transcription)
                            processedCount += 1
                            if processedCount == files.count {
                                print("Total audio duration: \(String(format: "%.2f", totalDuration)) seconds")
                                let totalEndTime = Date().timeIntervalSince1970
                                let elapsedTime = totalEndTime - totalStartTime
                                print("Total transcription time: \(String(format: "%.2f", elapsedTime)) seconds")
                            }
                        }
                    }
                }
            }
        }
    }

    func transcribeFile(_ file: RawFile, level: TranscriptionQuality = .low, completion: @escaping (String?) -> Void) {
        let backgroundQueue = DispatchQueue.global(qos: .background)
        backgroundQueue.async {
            self.transcribe(audioFile: file, level: level) { result in
                if (result.status == .success) {
                    if let transcription = result.transcription,
                       let transcriptionDuration = result.transcriptionDuration {
                        print(file.url.lastPathComponent)
                        print(transcription)
                        print("Audio file duration: \(String(format: "%.2f", file.duration)) seconds")
                        print("Transcription time: \(String(format: "%.2f", transcriptionDuration)) seconds")
                        completion(transcription)
                    }
                }
            }
        }
    }
}
