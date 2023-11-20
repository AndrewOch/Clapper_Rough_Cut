import Foundation

protocol AudioSynchronizerProtocol {
    func syncByWaveform(scenes: [FileSystemElement], completion: @escaping (FileSystemElement?) -> Void)
    func syncByWaveform(scene: FileSystemElement, completion: @escaping (FileSystemElement?) -> Void)
    func syncByTimecode(scenes: [FileSystemElement], completion: @escaping (FileSystemElement?) -> Void)
    func syncByTimecode(scene: FileSystemElement, completion: @escaping (FileSystemElement?) -> Void)
}

final class AudioSynchronizer: AudioSynchronizerProtocol {
    let document: ClapperRoughCutDocument
    
    init(document: ClapperRoughCutDocument) {
        self.document = document
    }
    
    func syncByTimecode(scenes: [FileSystemElement], completion: @escaping (FileSystemElement?) -> Void) {
        for scene in scenes {
            syncByTimecode(scene: scene) { result in
                completion(result)
            }
        }
    }
    
    func syncByTimecode(scene: FileSystemElement, completion: @escaping (FileSystemElement?) -> Void) {
        let files = document.project.fileSystem.allElements(where: { $0.containerId == scene.id })
        guard let referenceDate = files.min(by: { $0.createdAt ?? Date.distantPast < $1.createdAt ?? Date.distantPast })?.createdAt else {
            completion(nil)
            return
        }
        var timeOffsets = [UUID: Double]()
        var matchConfidence = [UUID: Double]()
        for file in files {
            if let createdAt = file.createdAt {
                let offset = createdAt.timeIntervalSince(referenceDate)
                timeOffsets[file.id] = offset
                matchConfidence[file.id] = 1.0
            }
        }
        var scene = scene
        scene.syncResult = AudioSyncResult(timeOffsets: timeOffsets, matchConfidence: matchConfidence)
        completion(scene)
    }
    
    func syncByWaveform(scenes: [FileSystemElement],
              completion: @escaping (FileSystemElement?) -> Void) {
        for scene in scenes {
            syncByWaveform(scene: scene) { result in
                completion(result)
            }
        }
    }
    
    func syncByWaveform(scene: FileSystemElement,
              completion: @escaping (FileSystemElement?) -> Void) {
        let mfccWrapper = MFCC_Wrapper()
        var timeOffsets: [UUID: Double] = [:]
        var matchConfidence: [UUID: Double] = [:]
        var syncedElements: [FileSystemElement] = []
        
        let files = document.project.fileSystem.allElements(where: { $0.containerId == scene.id })

        guard let baseFile = files.first, let baseMFCC = mfccWrapper.extractMFCCS(file: baseFile.url!) else {
            completion(nil)
            return
        }

        syncedElements.append(baseFile)

        let dispatchGroup = DispatchGroup()

        for file in files.dropFirst() {
            dispatchGroup.enter()

            DispatchQueue.global(qos: .userInitiated).async {
                guard let mfcc = mfccWrapper.extractMFCCS(file: file.url!) else {
                    dispatchGroup.leave()
                    return
                }

                let (distance, offset) = mfccWrapper.distanceAndOffsetDTW(mfccs1: baseMFCC, mfccs2: mfcc)

                DispatchQueue.main.async {
                    timeOffsets[file.id] = Double(offset)
                    matchConfidence[file.id] = Double(distance)
                    syncedElements.append(file)
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            var scene = scene
            scene.syncResult = AudioSyncResult(timeOffsets: timeOffsets, matchConfidence: matchConfidence)
            completion(scene)
        }
    }
}
