//
//  Clapper_Rough_CutApp.swift
//  Clapper Rough-Cut
//
//  Created by andrewoch on 03.02.2023.
//

import SwiftUI

@main
struct Clapper_Rough_CutApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: Clapper_Rough_CutDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
