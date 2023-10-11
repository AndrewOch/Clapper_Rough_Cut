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
        let scenes = project.findAllFileSystemElements(where: { $0.isScene })
        findMFCCS(in: scenes)
        matchByDistance(in: scenes)
        let endTime = Date().timeIntervalSince1970
        let elapsedTime = endTime - startTime
        print("Total matching time: \(elapsedTime) seconds")
    }

    func detachFiles(from take: FileSystemElement) {
        guard let scene = project.getContainer(forElementWithID: take.id) else { return }
        let elements = project.findAllFileSystemElements(where: { $0.containerId == take.id })
        registerUndo()
        for element in elements {
            project.moveFileSystemElement(withID: element.id, toFolderWithID: scene.id)
        }
        _ = project.deleteFileSystemElement(by: take.id)
    }

    private func findMFCCS(in scenes: [FileSystemElement]) {
        let python = MFCC_Wrapper()
        scenes.forEach { scene in
            project.findAllFileSystemElements(where: { $0.containerId == scene.id }).forEach { element in
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
        scenes.forEach { scene in
            var updatedScene = scene
            videos = project.findAllFileSystemElements(where: { $0.type == .video && $0.containerId == scene.id && $0.mfccs != nil })
            audios = project.findAllFileSystemElements(where: { $0.type == .audio && $0.containerId == scene.id && $0.mfccs != nil })
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
                if let match = bestMatch, let audio = project.firstFileSystemElement(where: { $0.id == match }) {
                    var take = FileSystemElement(title: .empty, type: .take)
                    project.addElement(take, toFolderWithID: scene.id)
                    project.moveFileSystemElement(withID: video.id, toFolderWithID: take.id)
                    project.moveFileSystemElement(withID: audio.id, toFolderWithID: take.id)
                }
            }
        }
    }
}
