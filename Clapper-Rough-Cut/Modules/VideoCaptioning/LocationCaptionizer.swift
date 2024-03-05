import CoreML
import AVFoundation
import Vision

final class LocationCaptionizer: VideoCaptionizerProtocol {
    private let exactConfidenceThreshold: Float = 0.6
    private let parentConfidenceThreshold: Float = 0.75
    private let model: VNCoreMLModel
    private let frameStep: Int = 20

    init() {
        model = try! VNCoreMLModel(for: location().model)
    }

    func captionVideo(file: FileSystemElement, completion: @escaping ([ClassificationElement]?) -> Void) {
        guard let videoURL = file.url else {
            DispatchQueue.main.async { completion(nil) }
            return
        }
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            self.processVideo(url: videoURL, withModel: model, frameStep: frameStep) { classes in
                DispatchQueue.main.async { completion(classes) }
            }
        }
    }

    func captionVideos(files: [FileSystemElement], completion: @escaping ([UUID:[ClassificationElement]?]) -> Void) {
        var results = [UUID: [ClassificationElement]]()
        DispatchQueue.global(qos: .userInitiated).async {
            let dispatchGroup = DispatchGroup()
            for file in files {
                dispatchGroup.enter()
                self.captionVideo(file: file) { classes in
                    results[file.id] = classes
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                completion(results)
            }
        }
    }
    
    private func processVideo(url: URL, withModel model: VNCoreMLModel, frameStep: Int, completion: @escaping ([ClassificationElement]?) -> Void) {
        let asset = AVAsset(url: url)
        
        do {
            let assetReader = try AVAssetReader(asset: asset)
            
            guard let videoTrack = asset.tracks(withMediaType: .video).first else {
                completion(nil)
                return
            }
            
            let readerOutputSettings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
            let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: readerOutputSettings)
            assetReader.add(readerOutput)
            assetReader.startReading()
            var frameCount = 0
            var maxClassConfidences = [String: Float]()
            var cumulativeParentClassConfidences = [String: Float]()
            
            while assetReader.status == .reading {
                if let sampleBuffer = readerOutput.copyNextSampleBuffer() {
                    frameCount += 1
                    if frameCount % frameStep == 0, let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                        let request = VNCoreMLRequest(model: model) { (request, error) in
                            guard error == nil, let results = request.results as? [VNClassificationObservation] else { return }
                            results.forEach { label in
                                let confidence = label.confidence
                                guard label.confidence > 0 else { return }
                                let classNames = label.identifier.components(separatedBy: "_")
                                cumulativeParentClassConfidences[classNames[0], default: 0.0] += confidence
                                if (confidence > maxClassConfidences[classNames[1]] ?? 0) {
                                    maxClassConfidences[classNames[1], default: 0.0] = confidence
                                }
                            }
                        }
                        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
                        try? handler.perform([request])
                    }
                }
            }
            var results = [ClassificationElement]()

            let adjustedResults = maxClassConfidences.map { key, value -> ClassificationElement in
                return ClassificationElement(className: key, confidence: value)
            }.filter { element in
                element.confidence >= exactConfidenceThreshold
            }
            let adjustedParentResults = cumulativeParentClassConfidences.map { key, value -> ClassificationElement in
                let adjustedConfidence = value / Float(frameCount) * Float(frameStep)
                return ClassificationElement(className: key, confidence: adjustedConfidence)
            }.filter { element in
                element.confidence >= parentConfidenceThreshold
            }
            results.append(contentsOf: adjustedResults)
            results.append(contentsOf: adjustedParentResults)
            completion(results)
        } catch {
            print("Failed to initialize AVAssetReader: \(error)")
            completion(nil)
        }
    }
}
