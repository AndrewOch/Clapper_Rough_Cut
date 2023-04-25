//
//  TranscriptionResult.swift
//  Clapper-Rough-Cut
//
//  Created by andrewoch on 13.04.2023.
//

struct TranscriptionResult {
    let status: TranscriptionResultStatus
    let transcription: String?
    let transcriptionDuration: Double?
}

enum TranscriptionResultStatus {
    case success
    case failure
}
