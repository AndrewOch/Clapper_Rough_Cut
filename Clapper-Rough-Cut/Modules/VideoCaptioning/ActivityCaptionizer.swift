import Foundation
import VisualActionKit
import AVFoundation

final class ActivityCaptionizer: VideoCaptionizerProtocol {
    private let confidenceThreshold: Double = 0.3

    func captionVideo(file: FileSystemElement, completion: @escaping ([ClassificationElement]?) -> Void) {
        guard let videoURL = file.url else {
            completion(nil)
            return
        }
        let asset = AVAsset(url: videoURL)
        DispatchQueue.global(qos: .userInitiated).async {
            Classifier.shared.classify(asset) { predictions in
                var results = [ClassificationElement]()
                predictions.forEach { label, confidence in
                    print(label, confidence)
                    guard confidence > self.confidenceThreshold else { return }
                    results.append(ClassificationElement(className: label, confidence: Float(confidence)))
                }
                DispatchQueue.main.async {
                    completion(results)
                }
            }
        }
    }

    func captionVideos(files: [FileSystemElement], completion: @escaping ([UUID:[ClassificationElement]?]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var results = [UUID: [ClassificationElement]?]()
        for file in files {
            dispatchGroup.enter()
            captionVideo(file: file) { predictions in
                results[file.id] = predictions
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion(results)
        }
    }
}
