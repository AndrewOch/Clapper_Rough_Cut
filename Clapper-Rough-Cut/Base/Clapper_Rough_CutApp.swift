import SwiftUI
import PythonKit
import AppKit

@main
struct Clapper_Rough_CutApp: App {

    init() {
        guard let path = Bundle.main.path(forResource: "python3.9", ofType: "") else {
            print("File not found")
            return
        }
        PythonLibrary.useLibrary(at: path)
    }

    var body: some Scene {
        DocumentGroup(newDocument: { ClapperRoughCutDocument() }) { _ in
            ContentView()
        }
    }
}
