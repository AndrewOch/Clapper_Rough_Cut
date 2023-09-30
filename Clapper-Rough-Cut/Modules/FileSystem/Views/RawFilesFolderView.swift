import SwiftUI

struct RawFilesFolderView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @Binding var folder: FileSystemElement
    var selected: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    folder.collapsed.toggle()
                } label: {
                    Image(systemName: folder.collapsed ? SystemImage.chevronRight.rawValue : SystemImage.chevronDown.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 8, height: 8)
                        .foregroundColor(Asset.dark.swiftUIColor)
                }
                .focusable(false)
                .buttonStyle(PlainButtonStyle())

                Button(action: {
//                    document.selectFolder(folder)
                }, label: {
                    HStack {
                        SystemImage.folderFill.imageView
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundColor(selected ? Asset.semiWhite.swiftUIColor : Asset.semiDark.swiftUIColor)
                        CustomLabel<BodyMediumStyle>(text: folder.title)
                            .lineLimit(1)
                            .foregroundColor(selected ? Asset.white.swiftUIColor : Asset.dark.swiftUIColor)
                        Spacer()
                    }
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(selected ? Asset.accentPrimary.swiftUIColor : Asset.light.swiftUIColor)
                    .cornerRadius(5)
                })
                .focusable(false)
                .buttonStyle(PlainButtonStyle())
            }
            if !folder.collapsed {
                ForEach(Array(folder.elements?.filter({ $0.isTake }) ?? [])) { take in
//                    RawTakeView(video: take.video,
//                                audio: take.audio,
//                                action: {
//                        document.selectTake(take)
//                    }, selected: document.project.selectedTake?.id == take.id)
//                    .padding(.leading, 20)
                }
                ForEach(Array(folder.elements?.filter({ $0.isFile }) ?? [])) { file in
//                    RawFileView(file: file, action: {
//                        document.selectFile(file)
//                    }, selected: document.project.selectedFile?.id == file.id)
//                    .padding(.leading, 20)
                }
            }
        }
        .padding(.vertical, 10)
    }
}
