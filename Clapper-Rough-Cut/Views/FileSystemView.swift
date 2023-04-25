//
//  FileSystemView.swift
//  Clapper-Rough-Cut
//
//  Created by andrewoch on 11.04.2023.
//

import SwiftUI

struct FileSystemView: View {
    
    @EnvironmentObject var document: ClapperRoughCutDocument
    @State private var width: CGFloat = 850
    @State private var fileSystemHeight: CGFloat = 600
    
    var body: some View {
        VSplitView {
            fileSystem
                .frame(minWidth: 850, idealWidth: width, maxWidth: .infinity)
                .frame(minHeight: 400, idealHeight: fileSystemHeight, maxHeight: .infinity)
                    .background(Color.white)
                    .onAppear {
                        width = 850
                        fileSystemHeight = 600
                    }
            RawFileDetailView(file: $document.project.selectedFile,
                              width: width)
        }
    }
    
    var fileSystem: some View {
        VStack {
            HStack {
                PrimaryButton(title: "Добавить файлы", imageName: "square.and.arrow.down", accesibilityIdentifier: "", enabled: .constant(true)) {
                    document.addRawFiles()
                }
                PrimaryButton(title: "Расшифровать", imageName: "rectangle.and.pencil.and.ellipsis", accesibilityIdentifier: "", enabled: $document.project.hasUntranscribedFiles)
                            {
                    document.transcribeFiles()
                }
                PrimaryButton(title: "Определить сцены", imageName: "film", accesibilityIdentifier: "", enabled: $document.project.canSortScenes) {
                    document.matchScenes()
                }
                PrimaryButton(title: "Определить дубли", imageName: "film.stack", accesibilityIdentifier: "", enabled: $document.project.hasUnmatchedSortedFiles) {
                    document.matchTakes()
                }
                PrimaryButton(title: "Экспорт", imageName: "rectangle.portrait.and.arrow.right", accesibilityIdentifier: "", enabled: .constant(false)) {
                }
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)
            ZStack {
                Color.black.opacity(0.8)
                ScrollView {
                    LazyVStack {
                        RawFilesFolderView(folder: document.project.unsortedFolder, collapsed: document.project.unsortedFolder.collapsed)
                        ForEach(document.project.phraseFolders) { folder in
                            RawFilesFolderView(folder: folder, collapsed: folder.collapsed)
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
        }
    }
}

struct FileSystemView_Previews: PreviewProvider {
    static var previews: some View {
        FileSystemView()
    }
}
