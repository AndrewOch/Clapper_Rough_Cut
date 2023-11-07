import SwiftUI

enum HeaderMenuOption {
    case none
    case base
    case file
    case edit
    case script
    case sort
    
    static var ids: [HeaderMenuOption: UUID] {
        var ids: [HeaderMenuOption: UUID] = [:]
        ids[.base] = UUID()
        ids[.file] = UUID()
        ids[.edit] = UUID()
        ids[.script] = UUID()
        ids[.sort] = UUID()
        return ids
    }
}

struct HeaderView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @Binding var popupPositions: [HeaderMenuOption: CGPoint]
    @State var menuIds: [HeaderMenuOption: UUID] = HeaderMenuOption.ids

    var body: some View {
        HStack {
            ImageButton<ImageButtonLogoStyle>(image: Asset.logo.swiftUIImage,
                                              enabled: .constant(true)) {
                document.states.selectedHeaderOption = .base
            }
                                              .padding(.horizontal, 10)
                                              .padding(.bottom, 5)
                                              .background(GeometryReader { buttonGeometry in
                                                  Color.clear
                                                      .onAppear {
                                                          let buttonFrame = buttonGeometry.frame(in: .global)
                                                          popupPositions[.base] = CGPoint(x: buttonFrame.minX + (ImageButtonLogoStyle.imageSize / 4),
                                                                                          y: (buttonFrame.maxY / 2) + (ImageButtonLogoStyle.imageSize / 6))
                                                      }
                                              })
                                              .onHover(perform: { hovering in
                                                  if hovering &&
                                                        document.states.selectedHeaderOption != .base &&
                                                        document.states.selectedHeaderOption != .none {
                                                      document.states.selectedHeaderOption = .base

                                                  }
                                              })
            HStack {
                RoundedButton<RoundedButtonHeaderMenuStyle>(title: L10n.file.firstWordCapitalized,
                                                            enabled: .constant(true)) {
                    document.states.selectedHeaderOption = .file
                }
                                                            .popup(id: menuIds[.file] ?? UUID(),
                                                                   condition: .constant(true),
                                                                   content: {
                                                                Color.black
                                                            })
                                                            .onHover(perform: { hovering in
                                                                if hovering &&
                                                                    document.states.selectedHeaderOption != .file &&
                                                                    document.states.selectedHeaderOption != .none {
                                                                    document.states.selectedHeaderOption = .file
                                                                }
                                                            })
                RoundedButton<RoundedButtonHeaderMenuStyle>(title: L10n.editSection.firstWordCapitalized,
                                                            enabled: .constant(true)) {
                    document.states.selectedHeaderOption = .edit
                }
                                                            .background(GeometryReader { buttonGeometry in
                                                                Color.clear
                                                                    .onAppear {
                                                                        let buttonFrame = buttonGeometry.frame(in: .global)
                                                                        popupPositions[.edit] = CGPoint(x: buttonFrame.minX, y: buttonFrame.maxY / 2)
                                                                    }
                                                            })
                                                            .onHover(perform: { hovering in
                                                                if hovering &&
                                                                      document.states.selectedHeaderOption != .edit &&
                                                                      document.states.selectedHeaderOption != .none {
                                                                    document.states.selectedHeaderOption = .edit

                                                                }
                                                            })
                RoundedButton<RoundedButtonHeaderMenuStyle>(title: L10n.script.firstWordCapitalized,
                                                            enabled: .constant(true)) {
                    document.states.selectedHeaderOption = .script
                }
                                                            .background(GeometryReader { buttonGeometry in
                                                                Color.clear
                                                                    .onAppear {
                                                                        let buttonFrame = buttonGeometry.frame(in: .global)
                                                                        popupPositions[.script] = CGPoint(x: buttonFrame.minX, y: buttonFrame.maxY / 2)
                                                                    }
                                                            })
                                                            .onHover(perform: { hovering in
                                                                if hovering &&
                                                                      document.states.selectedHeaderOption != .script &&
                                                                      document.states.selectedHeaderOption != .none {
                                                                    document.states.selectedHeaderOption = .script

                                                                }
                                                            })
                RoundedButton<RoundedButtonHeaderMenuStyle>(title: L10n.sort.firstWordCapitalized,
                                                            enabled: .constant(true)) {
                    document.states.selectedHeaderOption = .sort
                }
                                                            .background(GeometryReader { buttonGeometry in
                                                                Color.clear
                                                                    .onAppear {
                                                                        let buttonFrame = buttonGeometry.frame(in: .global)
                                                                        popupPositions[.sort] = CGPoint(x: buttonFrame.minX, y: buttonFrame.maxY / 2)
                                                                    }
                                                            })
                                                            .onHover(perform: { hovering in
                                                                if hovering &&
                                                                      document.states.selectedHeaderOption != .sort &&
                                                                      document.states.selectedHeaderOption != .none {
                                                                    document.states.selectedHeaderOption = .sort

                                                                }
                                                            })
            }
            Spacer()
        }
        .background(Asset.accentPrimary.swiftUIColor)
        .sheet(isPresented: $document.states.isExportViewPresented) {
            ExportView {
                document.export()
                document.states.isExportViewPresented.toggle()
            } closeAction: {
                document.states.isExportViewPresented.toggle()
            }
        }
    }
}
