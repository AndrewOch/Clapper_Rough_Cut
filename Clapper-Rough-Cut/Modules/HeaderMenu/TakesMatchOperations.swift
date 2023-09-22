import Foundation
import Accelerate
import AVFoundation

protocol TakesMatchOperations {
    func matchTakes()
    func detachFiles(from take: FileSystemElement)
}

extension ClapperRoughCutDocument: TakesMatchOperations {
    func matchTakes() {
        registerUndo()
        let startTime = Date().timeIntervalSince1970
        var scenes = project.findAllFileSystemElements(where: { $0.isScene }, excludeScenes: true, excludeTakes: true)
        findMFCCS(in: scenes)
        matchByDistance(in: scenes)
        let endTime = Date().timeIntervalSince1970
        let elapsedTime = endTime - startTime
        print("Total matching time: \(elapsedTime) seconds")
    }

    func detachFiles(from take: FileSystemElement) {
        guard let scene = project.getContainer(forElementWithID: take.id) else { return }
        registerUndo()
        for (key, _) in take.elements {
            project.moveFileSystemElement(withID: key, toFolderWithID: scene.id)
        }
        _ = project.deleteFileSystemElement(by: take.id)
    }

    private func findMFCCS(in scenes: [FileSystemElement]) {
        let python = MFCC_Wrapper()
        scenes.forEach { scene in
            scene.elements.values.forEach { element in
                guard element.isFile, element.mfccs == nil, let url = element.url else { return }
                var newFile = element
                newFile.mfccs = python.extractMFCCS(file: url)
                project.updateFileSystemElement(withID: element.id, newValue: newFile)
            }
        }
    }

    private func matchByDistance(in scenes: [FileSystemElement]) {
        let python = MFCC_Wrapper()
        var videos: [FileSystemElement] = []
        var audios: [FileSystemElement] = []
        var newFolders: [FileSystemElement] = []
        scenes.forEach { scene in
            var updatedScene = scene
            videos = scene.elements.values.filter({ $0.type == .video && $0.mfccs != nil })
            audios = scene.elements.values.filter({ $0.type == .audio && $0.mfccs != nil })
            for video in videos {
                guard let videoMFCCS = video.mfccs else { continue }
                var bestMatch: UUID? = nil
                var bestRatio = Float.greatestFiniteMagnitude
                for audio in audios {
                    guard let audioMFCCS = audio.mfccs else { continue }
                    let distance = python.distanceDTW(mfccs1: audioMFCCS, mfccs2: videoMFCCS)
                    if bestRatio > distance {
                        bestMatch = audio.id
                        bestRatio = distance
                    }
                }
                if let match = bestMatch, let audio = scene.elements[match] {
                    var take = FileSystemElement(title: .empty, type: .take)
                    project.addElement(take, toFolderWithID: scene.id)
                    project.moveFileSystemElement(withID: video.id, toFolderWithID: take.id)
                    project.moveFileSystemElement(withID: audio.id, toFolderWithID: take.id)
                }
            }
        }
    }
}
