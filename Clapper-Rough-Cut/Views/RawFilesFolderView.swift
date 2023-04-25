//
//  RawFilesFolderView.swift
//  Clapper-Rough-Cut
//
//  Created by andrewoch on 13.04.2023.
//

import SwiftUI

struct RawFilesFolderView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @State var folder: RawFilesFolder
    @State var collapsed: Bool
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    collapsed.toggle()
                } label: {
                    Image(systemName: collapsed ? "chevron.right" : "chevron.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 8, height: 8)
                }
                .focusable(false)
                .buttonStyle(PlainButtonStyle())
                Image(systemName: "folder")
                Text(folder.title).lineLimit(1)
                Spacer()
            }
            if !collapsed {
                ForEach(folder.takes) { take in
                    RawTakeView(video: take.video,
                                audio: take.audio,
                                action: {
                        document.selectTake(take)
                    }, selected: document.project.selectedTake?.id == take.id)
                    .padding(.leading, 20)
                }
                ForEach(folder.files) { file in
                    RawFileView(file: file, action: {
                        document.selectFile(file)
                    }, selected: document.project.selectedFile?.id == file.id)
                    .padding(.leading, 20)
                }
            }
        }
        .padding(.vertical, 10)
    }
}
