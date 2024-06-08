import Foundation

struct SceneMatchError: Error {
    let fileId: UUID
    let underlyingError: Error

    init(fileId: UUID, underlyingError: Error) {
        self.fileId = fileId
        self.underlyingError = underlyingError
    }

    var localizedDescription: String {
        return "\(underlyingError.localizedDescription) (File ID: \(fileId.uuidString))"
    }
}
