//
//  WhisperAudioTranscriber.swift
//  Clapper Rough-Cut
//
//  Created by andrewoch on 08.04.2023.
//

import Foundation
import AVFoundation

protocol AudioTranscriber {
    func transcribeFiles(_ files: [RawFile], completion: @escaping (URL, String?) -> Void)
    func transcribeFile(_ file: RawFile, completion: @escaping (String?) -> Void)
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
    
    private var whisperModel: String {
        guard let path = Bundle.main.path(forResource: "ggml-base", ofType: ".bin") else {
            print("File not found")
            return ""
        }
        return path
    }
    
    private func transcribe(audioFile: RawFile, completion: @escaping (TranscriptionResult) -> Void) {
        let startTime = Date().timeIntervalSince1970
        converter.convertAudioFile(audioFile.url) { result in
            switch result {
            case .success(let outputURL):
                let tmpFile = outputURL.path
                print("Conversion successful! Output file saved to: \(outputURL.path)")
                if FileManager.default.fileExists(atPath: tmpFile) {
                    var numThreads = "4"
                    var numProcesses = "2"
                    if audioFile.duration > 100 {
                        numThreads = "1"
                        numProcesses = "8"
                    }
                    print("TMP file " + tmpFile)
                    do {
                        let result = try ScriptRunner.safeShell([self.whisperScript , "-t", numThreads, "-p", numProcesses, "-l", "ru", "-m", self.whisperModel, "-nt", tmpFile])
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
    
    func transcribeFiles(_ files: [RawFile], completion: @escaping (URL, String?) -> Void) {
        let totalStartTime = Date().timeIntervalSince1970
        var totalDuration: Double = 0
        var processedCount = 0
        for file in files {
            transcribe(audioFile: file) { result in
                if (result.status == .success) {
                    if let transcription = result.transcription,
                       let transcriptionDuration = result.transcriptionDuration
                    {
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
    
    func transcribeFile(_ file: RawFile, completion: @escaping (String?) -> Void) {
        transcribe(audioFile: file) { result in
            if (result.status == .success) {
                if let transcription = result.transcription,
                   let transcriptionDuration = result.transcriptionDuration
                {
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
