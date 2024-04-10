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
        let scenes = project.fileSystem.allElements(where: { $0.isScene })
        findMFCCS(in: scenes)
        matchByDistance(in: scenes)
        let endTime = Date().timeIntervalSince1970
        let elapsedTime = endTime - startTime
        print("Total matching time: \(elapsedTime) seconds")
    }

    func detachFiles(from take: FileSystemElement) {
        guard let scene = project.fileSystem.getContainer(forElementWithID: take.id) else { return }
        let elements = project.fileSystem.allElements(where: { $0.containerId == take.id })
        registerUndo()
        for element in elements {
            project.fileSystem.moveElement(withID: element.id, toFolderWithID: scene.id)
        }
        _ = project.fileSystem.deleteElement(by: take.id)
    }

    private func findMFCCS(in scenes: [FileSystemElement]) {
        scenes.forEach { scene in
            project.fileSystem.allElements(where: { $0.containerId == scene.id }).forEach { element in
                guard element.isFile, element.mfccs == nil, let url = element.url else { return }
                var newFile = element
                mfccMatcher.extractMFCCs(fileURL: url) { mfccs in
                    newFile.mfccs = mfccs
                    self.project.fileSystem.updateElement(withID: element.id, newValue: newFile)
                }
            }
        }
    }

    private func matchByDistance(in scenes: [FileSystemElement]) {
        var videos: [FileSystemElement] = []
        var audios: [FileSystemElement] = []
        scenes.forEach { scene in
            videos = project.fileSystem.allElements(where: { $0.type == .video && $0.containerId == scene.id && $0.mfccs != nil })
            audios = project.fileSystem.allElements(where: { $0.type == .audio && $0.containerId == scene.id && $0.mfccs != nil })
            for video in videos {
                guard let videoMFCCS = video.mfccs else { continue }
                var bestMatch: UUID? = nil
                var bestRatio = Float.greatestFiniteMagnitude
                for audio in audios {
                    guard let audioMFCCS = audio.mfccs else { continue }
                    mfccMatcher.distanceDTW(mfccs1: audioMFCCS, mfccs2: videoMFCCS) { distance in
                        guard let distance = distance else { return }
                        if bestRatio > distance {
                            bestMatch = audio.id
                            bestRatio = distance
                        }
                    } // TODO: - Проверить потоки (чтобы код ниже выполнялся после цикла)
                }
                if let match = bestMatch, let audio = project.fileSystem.elementById(match) {
                    let take = FileSystemElement(title: .empty, type: .take)
                    project.fileSystem.addElement(take, toFolderWithID: scene.id)
                    project.fileSystem.moveElement(withID: video.id, toFolderWithID: take.id)
                    project.fileSystem.moveElement(withID: audio.id, toFolderWithID: take.id)
                }
            }
        }
    }
}
