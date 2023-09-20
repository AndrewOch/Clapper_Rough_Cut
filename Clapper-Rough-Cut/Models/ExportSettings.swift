import Foundation

struct ExportSettings: Identifiable, Codable {
    var id = UUID()
    var path: String
    var directoryName: String
    var method: FileExportMethod

    init() {
        if let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
            path = downloadsDirectory.path
        } else {
            path = "/"
        }
        directoryName = "Rough-Cut export"
        method = .copy
    }
}

enum FileExportMethod: Codable {
    case move
    case copy
}
