//
//  RawTakeView.swift
//  Clapper-Rough-Cut
//
//  Created by andrewoch on 14.04.2023.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct RawTakeView: View {
    @State var video: RawFile
    @State var audio: RawFile

    var action: () -> Void
    var selected: Bool
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack {
                HStack {
                    getFileImage(type: video.type)
                    Text(video.url.lastPathComponent)
                        .lineLimit(1)
                    Spacer()
                    if video.transcription != nil {
                        Image(systemName: "rectangle.and.pencil.and.ellipsis")
                            .foregroundColor(.secondary)
                    }
                    let minutes = Int(video.duration / 60)
                    let seconds = Int(video.duration.truncatingRemainder(dividingBy: 60))
                    let formattedDuration = String(format: "%02d:%02d", minutes, seconds)
                    Text(formattedDuration)
                    Text(formatDate(date: video.createdAt))
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 2)
                HStack {
                    getFileImage(type: audio.type)
                    Text(audio.url.lastPathComponent)
                        .lineLimit(1)
                    Spacer()
                    if audio.transcription != nil {
                        Image(systemName: "rectangle.and.pencil.and.ellipsis")
                            .foregroundColor(.secondary)
                    }
                    let minutes = Int(audio.duration / 60)
                    let seconds = Int(audio.duration.truncatingRemainder(dividingBy: 60))
                    let formattedDuration = String(format: "%02d:%02d", minutes, seconds)
                    Text(formattedDuration)
                    Text(formatDate(date: audio.createdAt))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 5)
            .padding(.vertical, selected ? 5 : 2)
            .cornerRadius(5)
        }
        .focusable(false)
        .buttonStyle(PlainButtonStyle())
        .background(selected ? Color.purple.opacity(0.3) : .gray.opacity(0.3))
        .cornerRadius(5)
    }
    
    private func getFileImage(type: RawFileType?) -> Image {
        if let type = type {
            if type == .audio {
                return Image(systemName: "mic")
            } else if type == .video {
                return Image(systemName: "video.square")
            }
        }
        return Image(systemName: "doc")
    }
    
    private func formatDate(date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            formatter.locale = .current
            return formatter.string(from: date)
        }
}
