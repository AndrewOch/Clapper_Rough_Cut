import CoreML
import AVFoundation
import Vision

enum RecognitionQuality {
    case high, low
}

protocol VideoCaptionizerProtocol {
    func captionVideo(file: FileSystemElement, quality: RecognitionQuality, completion: @escaping (FileSystemElement) -> Void)
    func captionVideos(files: [FileSystemElement], quality: RecognitionQuality, completion: @escaping ([FileSystemElement]) -> Void)
}

final class VideoCaptionizer: VideoCaptionizerProtocol {
    private let confidenceThreshold: Float = 0.2

    func captionVideo(file: FileSystemElement, quality: RecognitionQuality, completion: @escaping (FileSystemElement) -> Void) {
        guard let videoURL = file.url else {
            DispatchQueue.main.async { completion(file) }
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let model: VNCoreMLModel
            do {
                switch quality {
                case .high:
                    model = try VNCoreMLModel(for: yolov8x().model)
                case .low:
                    model = try VNCoreMLModel(for: yolov8n().model)
                }
            } catch {
                print("Error loading model: \(error)")
                DispatchQueue.main.async { completion(file) }
                return
            }

            let frameStep: Int = quality == .high ? 20 : 10

            self.processVideo(url: videoURL, withModel: model, frameStep: frameStep) { classes in
                var updatedFile = file
                updatedFile.videoClasses = classes
                DispatchQueue.main.async { completion(updatedFile) }
            }
        }
    }

    func captionVideos(files: [FileSystemElement], quality: RecognitionQuality, completion: @escaping ([FileSystemElement]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let dispatchGroup = DispatchGroup()
            var updatedFiles: [FileSystemElement] = []

            for file in files {
                dispatchGroup.enter()
                self.captionVideo(file: file, quality: quality) { updatedFile in
                    updatedFiles.append(updatedFile)
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                completion(updatedFiles)
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

            let adjustedResults = classificationResults.map { element -> ClassificationElement in
                let adjustedConfidence = cumulativeClassConfidences[element.className, default: 0.0] / Float(frameCount) * Float(frameStep)
                return ClassificationElement(className: element.className, confidence: adjustedConfidence)
            }.filter { element in
                element.confidence >= confidenceThreshold
            }
            completion(adjustedResults.unique())
        } catch {
            print("Failed to initialize AVAssetReader: \(error)")
            completion(nil)
        }
    }
}
