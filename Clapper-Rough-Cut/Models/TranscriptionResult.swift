struct TranscriptionResult {
    let status: TranscriptionResultStatus
    let transcription: String?
    let transcriptionDuration: Double?
}

enum TranscriptionResultStatus {
    case success
    case failure
}
