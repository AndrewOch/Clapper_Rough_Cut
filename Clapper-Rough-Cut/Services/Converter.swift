//
//  Converter.swift
//  Clapper Rough-Cut
//
//  Created by andrewoch on 08.04.2023.
//

import Foundation
import AVFoundation
import AudioKit

class Converter {
    func convertAudioFile(_ sourceFileURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let outputFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString).appendingPathExtension("wav")
        var options = FormatConverter.Options()
        options.format = .wav
        options.sampleRate = 16000
        let converter = FormatConverter(inputURL: sourceFileURL, outputURL: outputFileURL, options: options)
        converter.start(completionHandler: { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(outputFileURL))
            }
        })
    }
}
