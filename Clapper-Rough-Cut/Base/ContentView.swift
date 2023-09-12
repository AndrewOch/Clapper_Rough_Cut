import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @State private var isExportViewPresented = false
    @State private var popupPositions: [HeaderMenuOption: CGPoint] = [:]

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(popupPositions: $popupPositions)
            HSplitView {
                FileSystemView()
                ScriptView()
            }
        }
        .onTapGesture {
            document.states.selectedHeaderOption = .none
        }
        .overlay {
            ZStack {
                switch document.states.selectedHeaderOption {
                case .none: EmptyView()
                case .base:
                    CustomContextMenuView(position: popupPositions[.base] ?? .zero,
                                          sections: document.headerMenuConfiguration?.base ?? [])
                case .project:
                    CustomContextMenuView(position: popupPositions[.project] ?? .zero,
                                          sections: document.headerMenuConfiguration?.project ?? [])
                case .search:
                    CustomContextMenuView(position: popupPositions[.search] ?? .zero,
                                          sections: document.headerMenuConfiguration?.search ?? [])
                case .script:
                    CustomContextMenuView(position: popupPositions[.script] ?? .zero,
                                          sections: document.headerMenuConfiguration?.script ?? [])
                case .sort:
                    CustomContextMenuView(position: popupPositions[.sort] ?? .zero,
                                          sections: document.headerMenuConfiguration?.sort ?? [])
                }
            }
        }
    }
}
