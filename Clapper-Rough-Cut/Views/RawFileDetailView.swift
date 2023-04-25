//
//  RawFileDetailView.swift
//  Clapper-Rough-Cut
//
//  Created by andrewoch on 12.04.2023.
//

import SwiftUI

struct RawFileDetailView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @Binding var file: RawFile?
    @State var width: CGFloat = 850
    @State private var isModalPresented = false
    
    var body: some View {
        VStack {
            if let file = file {
                HStack {
                    getFileImage(type: file.type)
                        .foregroundColor(.black)
                    Text(file.url.lastPathComponent)
                        .lineLimit(1)
                        .foregroundColor(.black)
                    Spacer()
                    let minutes = Int(file.duration / 60)
                    let seconds = Int(file.duration.truncatingRemainder(dividingBy: 60))
                    let formattedDuration = String(format: "%02d:%02d", minutes, seconds)
                    Text(formattedDuration)
                        .foregroundColor(.black)
                    Text(formatDate(date: file.createdAt))
                        .foregroundColor(.gray)
                }.padding(.bottom)
                if let transcription = file.transcription {
                    VStack {
                        HStack {
                            Image(systemName: "rectangle.and.pencil.and.ellipsis")
                                .foregroundColor(.gray)
                            Text("Распознанная речь")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        ScrollView {
                            HStack {
                                Text(transcription)
                                    .foregroundColor(.black)
                                Spacer()
                            }
                        }
                    }
                } else {
                    HStack {
                        PrimaryButton(title: "Расшифровать", imageName: "rectangle.and.pencil.and.ellipsis", accesibilityIdentifier: "", enabled: .constant(true)) {
                            document.transcribeFile(file)
                        }
                        Spacer()
                    }
                }
                if let folder = document.getPhraseFolderForFile(file) {
                    VStack {
                        HStack {
                            Image(systemName: "folder")
                                .foregroundColor(.gray)
                            Text(folder.title)
                                .foregroundColor(.gray)
                            Spacer()
                            PrimaryButton(title: "Заменить сцену",
                                          imageName: "film",
                                          accesibilityIdentifier: "",
                                          enabled: .constant(true)) {
                                isModalPresented.toggle()
                            }
                        }
                    }
                } else {
                    VStack {
                        HStack {
                            PrimaryButton(title: "Определить сцену",
                                          imageName: "film",
                                          accesibilityIdentifier: "",
                                          enabled: .constant(file.transcription != nil)) {
                                document.matchSceneForFile(file)
                            }
                            PrimaryButton(title: "Выбрать сцену",
                                          imageName: "film",
                                          accesibilityIdentifier: "",
                                          enabled: .constant(true)) {
                                isModalPresented.toggle()
                            }
                            Spacer()
                        }
                    }
                }
            }
            Spacer()
        }.padding()
        .frame(minWidth: 850, idealWidth: width, maxWidth: .infinity)
        .frame(minHeight: 200, maxHeight: .infinity)
        .background(Color.white)
        .sheet(isPresented: $isModalPresented) {
            if let file = file {
                SelectPhraseMatchView(file: file) { phrase in
                    document.manualMatch(file: file, phrase: phrase)
                    isModalPresented.toggle()
                } closeAction: {
                    isModalPresented.toggle()
                }
            }
        }
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
            formatter.dateStyle = .long
            formatter.timeStyle = .short
            formatter.locale = .current
            return formatter.string(from: date)
        }
}

struct RawFileDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RawFileDetailView(file: .constant(RawFile(url: URL(fileURLWithPath: "tmpFile.MOV"), duration: 100, type: .audio, createdAt: Date())), width: 850)
    }
}
