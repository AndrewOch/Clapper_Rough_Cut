import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        HSplitView {
            FileSystemView()
            ScriptView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
