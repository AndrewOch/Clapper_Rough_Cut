import Foundation
import Accelerate
import AVFoundation

protocol TakesMatchOperations {
    func matchTakes()
    func detachFiles(from take: RawTake)
}

extension ClapperRoughCutDocument: TakesMatchOperations {
    func matchTakes() {
        registerUndo()
        let startTime = Date().timeIntervalSince1970
        let python = MFCC_Wrapper()

        for folder in project.phraseFolders {
            folder.files.filter({ $0.mfccs == nil }).forEach { file in
                file.mfccs = python.extractMFCCS(file: file.url)
            }
            let videos = folder.files.filter({ $0.type == .video && $0.mfccs != nil })
            let audios = folder.files.filter({ $0.type == .audio && $0.mfccs != nil })

            for video in videos {
                if let videoMFCCS = video.mfccs {
                    var bestMatch: UUID? = nil
                    var bestRatio = Float.greatestFiniteMagnitude
                    for audio in audios {
                        if let audioMFCCS = audio.mfccs {
                            let distance = python.distanceDTW(mfccs1: audioMFCCS, mfccs2: videoMFCCS)
                            if bestRatio > distance {
                                bestMatch = audio.id
                                bestRatio = distance
                            }
                        }
                    }
                    if let match = bestMatch {
                        if let audio = folder.files.first(where: { $0.id == match }) {
                            folder.takes.append(RawTake(video: video, audio: audio))
                            folder.files.removeAll { file in file.id == video.id || file.id == audio.id }
                        }
                    }
                }
            }
        }
        let endTime = Date().timeIntervalSince1970
        let elapsedTime = endTime - startTime
        print("Total matching time: \(elapsedTime) seconds")
        unselectAll()
        updateStatus()
    }

    func detachFiles(from take: RawTake) {
        registerUndo()
        let video = take.video
        let audio = take.audio
        if let index = project.phraseFolders.firstIndex(where: { folder in folder.takes.contains { t in t.id == take.id } }) {
            project.phraseFolders[index].files.append(contentsOf: [video, audio])
            project.phraseFolders[index].takes.removeAll { t in t.id == take.id }
        }
        unselectAll()
        updateStatus()
    }
}
