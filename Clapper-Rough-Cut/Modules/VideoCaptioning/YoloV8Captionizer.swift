import CoreML
import AVFoundation
import Vision

final class YoloV8Captionizer: VideoCaptionizerProtocol {
    private let confidenceThreshold: Float = 0.4
    private let model: VNCoreMLModel
    private let frameStep: Int = 20

    init() {
        model = try! VNCoreMLModel(for: yolov8x().model)
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
            var classificationResults = [ClassificationElement]()
            var cumulativeClassConfidences = [String: Float]()
            
            while assetReader.status == .reading {
                if let sampleBuffer = readerOutput.copyNextSampleBuffer() {
                    frameCount += 1
                    
                    if frameCount % frameStep == 0, let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                        var frameClassCounts = [String: Int]()
                        let request = VNCoreMLRequest(model: model) { (request, error) in
                            guard error == nil, let results = request.results as? [VNRecognizedObjectObservation] else { return }
                            results.forEach { observation in
                                observation.labels.forEach { label in
                                    guard label.confidence > 0 else { return }
                                    let currentCount = frameClassCounts[label.identifier, default: 0]
                                    frameClassCounts[label.identifier] = currentCount + 1
                                    
                                    for i in 1...(currentCount + 1) {
                                        let className = i > 1 ? "\(i) \(label.identifier)" : label.identifier
                                        let element = ClassificationElement(className: className, confidence: label.confidence)
                                        classificationResults.append(element)
                                        cumulativeClassConfidences[className, default: 0.0] += label.confidence
                                    }
                                }
                            }
                        }

                        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
                        try? handler.perform([request])
                    }
                }
            }

            let adjustedResults = cumulativeClassConfidences.map { key, value -> ClassificationElement in
                let adjustedConfidence = value / Float(frameCount) * Float(frameStep)
                return ClassificationElement(className: key, confidence: adjustedConfidence)
            }.filter { element in
                element.confidence >= confidenceThreshold
            }
            completion(adjustedResults)
        } catch {
            print("Failed to initialize AVAssetReader: \(error)")
            completion(nil)
        }
    }
}
