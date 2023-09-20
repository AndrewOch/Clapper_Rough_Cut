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
        findMFCCS()
        matchByDistance()
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
    
    private func findMFCCS() {
        let python = MFCC_Wrapper()
        var newFolders: [RawFilesFolder] = []
        project.phraseFolders.forEach { folder in
            var newFolder = folder
            newFolder.files = []
            folder.files.forEach { file in
                if file.mfccs != nil { 
                    newFolder.files.append(file)
                    return
                }
                var newFile = file
                newFile.mfccs = python.extractMFCCS(file: file.url)
                newFolder.files.append(newFile)
            }
            newFolders.append(newFolder)
        }
        project.phraseFolders = newFolders
    }
    
    private func matchByDistance() {
        let python = MFCC_Wrapper()
        var videos: [RawFile] = []
        var audios: [RawFile] = []
        var newFolders: [RawFilesFolder] = []
        for folder in project.phraseFolders {
            var newFolder = folder
            videos = folder.files.filter({ $0.type == .video && $0.mfccs != nil })
            audios = folder.files.filter({ $0.type == .audio && $0.mfccs != nil })
            
            for video in videos {
                guard let videoMFCCS = video.mfccs else { continue }
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
                if let match = bestMatch, let audio = folder.files.first(where: { $0.id == match }) {
                    newFolder.takes.append(RawTake(video: video, audio: audio))
                    newFolder.files.removeAll { file in file.id == video.id || file.id == audio.id }
                }
            }
            newFolders.append(newFolder)
        }
        project.phraseFolders = newFolders
    }
}
