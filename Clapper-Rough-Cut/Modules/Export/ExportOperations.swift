import Foundation
import AppKit

protocol ExportOperations {
    func selectExportFolder()
    func export()
}

extension ClapperRoughCutDocument: ExportOperations {
    func selectExportFolder() {
        let dialog = NSOpenPanel()
        dialog.title                   = "Choose script file"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = true
        dialog.allowsMultipleSelection = false
        dialog.allowedContentTypes     = [.directory]

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            if let result = dialog.url {
                project.exportSettings.path = result.path
            }
        }
    }

    func export() {
        let exportSettings = project.exportSettings
        let exportDirectory = URL(fileURLWithPath: exportSettings.path)
        var root = project.fileSystem.root
        root.title = exportSettings.directoryName
        exportFolder(root: exportDirectory, folder: root)
    }

    private func exportFolder(root: URL, folder: FileSystemElement) {
        let exportFolderURL = root.appendingPathComponent(folder.title)
        createFolder(at: exportFolderURL)
        project.fileSystem.allElements(where: { $0.isFile && $0.containerId == folder.id }).forEach { file in
            guard let url = file.url else { return }
            let fileName = url.lastPathComponent
            copyFile(from: url, to: exportFolderURL.appendingPathComponent(fileName))
        }
        createSceneXML(from: folder, at: exportFolderURL)
        project.fileSystem.allElements(where: { $0.isFolder && $0.containerId == folder.id }).forEach {
            exportFolder(root: exportFolderURL, folder: $0)
        }
//        var takes: [FileSystemElement] = project.fileSystem.allElements(where: { $0.isTake && $0.containerId == folder.id })
//        takes.sort { take1, take2 in
//            let minCreatedAt1 = project.fileSystem.allElements(where: { $0.containerId == take1.id })
//                .min(by: compareByMinCreatedAt)?.createdAt
//            let minCreatedAt2 = project.fileSystem.allElements(where: { $0.containerId == take2.id })
//                .min(by: compareByMinCreatedAt)?.createdAt
//            if let min1 = minCreatedAt1, let min2 = minCreatedAt2 {
//                return min1 < min2
//            }
//            return false
//        }
//        var takeNum = 1
//        takes.forEach { take in
//            exportTake(root: exportFolderURL, take: take, num: takeNum)
//            takeNum += 1
//        }
    }

    private func compareByMinCreatedAt(_ element1: FileSystemElement, _ element2: FileSystemElement) -> Bool {
        if let createdAt1 = element1.createdAt, let createdAt2 = element2.createdAt {
            return createdAt1 < createdAt2
        }
        return false
    }

    private func exportTake(root: URL, take: FileSystemElement, num: Int) {
        let exportFolderURL = root.appendingPathComponent("Take \(num)")
        createFolder(at: exportFolderURL)
        project.fileSystem.allElements(where: { $0.isFile && $0.containerId == take.id }).forEach { file in
            guard let url = file.url else { return }
            let name = url.lastPathComponent
            copyFile(from: url, to: exportFolderURL.appendingPathComponent(name))
        }
    }

    private func createFolder(at url: URL) {
        let fileManager = FileManager.default
        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            print("Folder created successfully")
        } catch {
            print("Error creating folder: \(error.localizedDescription)")
        }
    }

    private func copyFile(from sourceURL: URL, to destinationURL: URL) {
        let fileManager = FileManager.default
        do {
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            print("File copied successfully")
        } catch {
            print("Error copying file: \(error.localizedDescription)")
        }
    }

    private func createSceneXML(from folder: FileSystemElement, at destination: URL) {
        var xmlDocument = XMLDocument()
        project.fileSystem.allElements(where: { $0.isScene && $0.containerId == folder.id }).forEach { scene in
            let sequence = createSequenceForScene(scene: scene,
                                                  allElements: project.fileSystem.elementsDictionary)
            xmlDocument.addChild(sequence)
        }
        let xmlData = xmlDocument.xmlData(options: .nodePrettyPrint)
    }

    func createSequenceForScene(scene: FileSystemElement, allElements: [UUID: FileSystemElement]) -> XMLElement {
        let sequence = XMLElement(name: "sequence")
        let media = XMLElement(name: "media")
        let video = XMLElement(name: "video")
        let track = XMLElement(name: "track")

        for (elementID, offset) in scene.syncResult?.timeOffsets ?? [:] {
            guard let element = allElements[elementID] else { continue }

            let clipItem = XMLElement(name: "clipitem")
            clipItem.addChild(XMLElement(name: "name", stringValue: element.title))
            clipItem.addChild(XMLElement(name: "start", stringValue: "\(secondsToFrames(offset))"))
            clipItem.addChild(XMLElement(name: "duration", stringValue: "\(secondsToFrames(element.duration ?? 0))"))

            track.addChild(clipItem)
        }

        video.addChild(track)
        media.addChild(video)
        sequence.addChild(media)
        return sequence
    }

    private func secondsToFrames(_ seconds: Double) -> Int {
        return Int(seconds * 25)
    }
}
