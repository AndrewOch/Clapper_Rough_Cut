import Foundation

protocol ProjectExporter {
    func exportScene(scene: FileSystemElement, elements: [FileSystemElement], to url: URL, fps: Double)
}
