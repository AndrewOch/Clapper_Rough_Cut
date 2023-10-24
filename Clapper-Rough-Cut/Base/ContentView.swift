import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.undoManager) var undoManager
    @EnvironmentObject var document: ClapperRoughCutDocument
    @State private var isExportViewPresented = false
    @State private var popupPositions: [HeaderMenuOption: CGPoint] = [:]
    @State var value: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(popupPositions: $popupPositions)
            HSplitView {
                FileSystemView()
                ScriptView()
            }
        }
        .onAppear {
            document.undoManager = undoManager
        }
        .onChange(of: self.undoManager) { undoManager in
            document.undoManager = undoManager
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
                case .file:
                    CustomContextMenuView(position: popupPositions[.file] ?? .zero,
                                          sections: document.headerMenuConfiguration?.file ?? [])
                case .edit:
                    CustomContextMenuView(position: popupPositions[.edit] ?? .zero,
                                          sections: document.headerMenuConfiguration?.edit ?? [])
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
