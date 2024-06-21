import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.undoManager) var undoManager
    @EnvironmentObject var document: ClapperRoughCutDocument

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
