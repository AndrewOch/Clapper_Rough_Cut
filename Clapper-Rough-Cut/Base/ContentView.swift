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
            popups
        }
    }

    var popups: some View {
        ZStack {
            ForEach(Array(document.states.popupPositions.keys), id: \.self) { key in
                if let (isPresented, content) = document.states.popupPositions[key] {
                    if isPresented.wrappedValue {
                        content
//                        Color.black
                    }
                }
            }
        }
    }
}
