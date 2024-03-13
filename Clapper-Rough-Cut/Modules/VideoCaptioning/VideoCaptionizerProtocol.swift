import Foundation

protocol VideoCaptionizerProtocol {
    func captionVideo(file: FileSystemElement, completion: @escaping ([ClassificationElement]?) -> Void)
    func captionVideos(files: [FileSystemElement], completion: @escaping ([UUID:[ClassificationElement]?]) -> Void)
}
