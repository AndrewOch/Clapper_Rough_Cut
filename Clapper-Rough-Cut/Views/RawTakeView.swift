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
                    FileIcon(type: video.type)
                    Text(video.url.lastPathComponent)
                        .lineLimit(1)
                    Spacer()
                    if video.transcription != nil {
                        TranscribedIcon()
                    }
                    Text(Formatter.formatDuration(duration: video.duration))
                    Text(Formatter.formatDate(date: video.createdAt))
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 2)
                HStack {
                    FileIcon(type: audio.type)
                    Text(audio.url.lastPathComponent)
                        .lineLimit(1)
                    Spacer()
                    if audio.transcription != nil {
                        TranscribedIcon()
                    }
                    Text(Formatter.formatDuration(duration: audio.duration))
                    Text(Formatter.formatDate(date: audio.createdAt))
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
}
