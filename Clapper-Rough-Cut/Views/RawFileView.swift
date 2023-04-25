//
//  RawFilesView.swift
//  Clapper Rough-Cut
//
//  Created by andrewoch on 04.02.2023.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct RawFileView: View {
    @State var file: RawFile
    var action: () -> Void
    var selected: Bool
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                getFileImage(type: file.type)
                Text(file.url.lastPathComponent)
                    .lineLimit(1)
                Spacer()
                if file.transcription != nil {
                    Image(systemName: "rectangle.and.pencil.and.ellipsis")
                        .foregroundColor(.secondary)
                }
                let minutes = Int(file.duration / 60)
                let seconds = Int(file.duration.truncatingRemainder(dividingBy: 60))
                let formattedDuration = String(format: "%02d:%02d", minutes, seconds)
                Text(formattedDuration)
                Text(formatDate(date: file.createdAt))
                    .foregroundColor(.secondary)
            }
        }
        .focusable(false)
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 5)
        .padding(.vertical, selected ? 5 : 1)
        .background(selected ? Color.purple.opacity(0.3) : Color.clear)
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
