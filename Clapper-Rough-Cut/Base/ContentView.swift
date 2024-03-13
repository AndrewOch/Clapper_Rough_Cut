import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.undoManager) var undoManager
    @EnvironmentObject var document: ClapperRoughCutDocument
    @State private var isExportViewPresented = false

    var body: some View {
        HSplitView {
            FileSystemView()
            ScriptView()
        }
        .onAppear {
            document.undoManager = undoManager
        }
        .onChange(of: self.undoManager) { undoManager in
            document.undoManager = undoManager
        }
    }
}
