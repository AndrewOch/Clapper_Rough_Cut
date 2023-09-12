import SwiftUI

enum HeaderMenuOption {
    case none
    case base
    case project
    case search
    case script
    case sort
}

struct HeaderView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @Binding var popupPositions: [HeaderMenuOption: CGPoint]

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
            HStack {
                RoundedButton<RoundedButtonHeaderMenuStyle>(title: L10n.project.firstWordCapitalized,
                                                            enabled: .constant(true)) {
                    document.states.selectedHeaderOption = .project
                }
                                                            .background(GeometryReader { buttonGeometry in
                                                                Color.clear
                                                                    .onAppear {
                                                                        let buttonFrame = buttonGeometry.frame(in: .global)
                                                                        popupPositions[.project] = CGPoint(x: buttonFrame.minX, y: buttonFrame.maxY / 2)
                                                                    }
                                                            })
                RoundedButton<RoundedButtonHeaderMenuStyle>(title: L10n.search.firstWordCapitalized,
                                                            enabled: .constant(true)) {
                    document.states.selectedHeaderOption = .search
                }
                                                            .background(GeometryReader { buttonGeometry in
                                                                Color.clear
                                                                    .onAppear {
                                                                        let buttonFrame = buttonGeometry.frame(in: .global)
                                                                        popupPositions[.search] = CGPoint(x: buttonFrame.minX, y: buttonFrame.maxY / 2)
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
