import Foundation
import AVFoundation
import AudioKit

class Converter {
    func convertAudioFile(_ sourceFileURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let outputFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString).appendingPathExtension("wav")
        var options = FormatConverter.Options()
        options.format = .wav
        options.sampleRate = 16_000
        let converter = FormatConverter(inputURL: sourceFileURL, outputURL: outputFileURL, options: options)
        converter.start(completionHandler: { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(outputFileURL))
            }
        })
    }

    func convertAudioFileToPCMArray(fileURL: URL, completionHandler: @escaping (Result<[Float], Error>) -> Void) {
        var options = FormatConverter.Options()
        options.format = .wav
        options.sampleRate = 16000
        options.bitDepth = 16
        options.channels = 1
        options.isInterleaved = false
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        let converter = FormatConverter(inputURL: fileURL, outputURL: tempURL, options: options)
        converter.start { error in
            if let error {
                completionHandler(.failure(error))
                return
            }
            let data = try! Data(contentsOf: tempURL) // Handle error here
            let floats = stride(from: 44, to: data.count, by: 2).map {
                return data[$0..<$0 + 2].withUnsafeBytes {
                    let short = Int16(littleEndian: $0.load(as: Int16.self))
                    return max(-1.0, min(Float(short) / 32767.0, 1.0))
                }
            }
            try? FileManager.default.removeItem(at: tempURL)
            completionHandler(.success(floats))
        }
    }
}
