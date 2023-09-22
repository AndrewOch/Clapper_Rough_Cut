import Foundation
import AVFoundation
import Dispatch

protocol AudioTranscriber {
    func transcribeFiles(_ files: [FileSystemElement], quality: TranscriptionQuality, completion: @escaping (FileSystemElement) -> Void)
    func transcribeFile(_ file: FileSystemElement, quality: TranscriptionQuality, completion: @escaping (FileSystemElement) -> Void)
}

public enum TranscriptionQuality {
    case low
    case high
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
        converter.convertAudioFile(url) { result in
            switch result {
            case .success(let outputURL):
                let tmpFile = outputURL.path
                print("Conversion successful! Output file saved to: \(outputURL.path)")
                if FileManager.default.fileExists(atPath: tmpFile) {
                    var numThreads = "4"
                    var numProcesses = "2"
                    if duration > 100 {
                        numThreads = "1"
                        numProcesses = "8"
                    }
                    print("TMP file " + tmpFile)
                    do {
                        let result = try ScriptRunner.safeShell([self.whisperScript,
                                                                 "-t", numThreads,
                                                                 "-p", numProcesses,
                                                                 "-l", "ru",
                                                                 "-m", model,
                                                                 "-nt", tmpFile])
                        let endTime = Date().timeIntervalSince1970
                        let resultTime = endTime - startTime
                        completion(TranscriptionResult(status: .success,
                                                       transcription: result,
                                                       transcriptionDuration: resultTime))
                    } catch {
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

    func transcribeFiles(_ files: [FileSystemElement], 
                         quality: TranscriptionQuality = .low,
                         completion: @escaping (FileSystemElement) -> Void) {
        let totalStartTime = Date().timeIntervalSince1970
        var totalDuration: Double = 0
        var processedCount = 0
        let backgroundQueue = DispatchQueue.global(qos: .background)
        for file in files {
            guard let url = file.url, let duration = file.duration else { return }
            backgroundQueue.async {
                self.transcribe(audioFile: file, quality: quality) { result in
                    guard result.status == .success,
                          let transcription = result.transcription,
                          let transcriptionDuration = result.transcriptionDuration else { return }
                    print(url.lastPathComponent)
                    print(transcription)
                    print("Audio file duration: \(String(format: "%.2f", duration)) seconds")
                    print("Transcription time: \(String(format: "%.2f", transcriptionDuration)) seconds")
                    totalDuration += duration
                    var newFile = file
                    newFile.transcription = transcription
                    completion(newFile)
                    processedCount += 1
                    if processedCount < files.count { return }
                    print("Total audio duration: \(String(format: "%.2f", totalDuration)) seconds")
                    let totalEndTime = Date().timeIntervalSince1970
                    let elapsedTime = totalEndTime - totalStartTime
                    print("Total transcription time: \(String(format: "%.2f", elapsedTime)) seconds")
                }
            }
        }
    }

    func transcribeFile(_ file: FileSystemElement, 
                        quality: TranscriptionQuality = .low,
                        completion: @escaping (FileSystemElement) -> Void) {
        guard let url = file.url, let duration = file.duration else { return }
        let backgroundQueue = DispatchQueue.global(qos: .background)
        backgroundQueue.async {
            self.transcribe(audioFile: file, quality: quality) { result in
                if (result.status == .success) {
                    if let transcription = result.transcription,
                       let transcriptionDuration = result.transcriptionDuration {
                        print(url.lastPathComponent)
                        print(transcription)
                        print("Audio file duration: \(String(format: "%.2f", duration)) seconds")
                        print("Transcription time: \(String(format: "%.2f", transcriptionDuration)) seconds")
                        var newFile = file
                        newFile.transcription = transcription
                        completion(newFile)
                    }
                }
            }
        }
    }
}
