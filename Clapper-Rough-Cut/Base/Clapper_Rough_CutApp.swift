//
//  Clapper_Rough_CutApp.swift
//  Clapper Rough-Cut
//
//  Created by andrewoch on 03.02.2023.
//

import SwiftUI
import PythonKit

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
        DocumentGroup(newDocument: { ClapperRoughCutDocument() }) { configuration in
            ContentView()
        }
    }
}
