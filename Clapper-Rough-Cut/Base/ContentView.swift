//
//  ContentView.swift
//  Clapper Rough Cut
//
//  Created by andrewoch on 03.02.2023.
//

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
