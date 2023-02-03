//
//  ContentView.swift
//  Clapper Rough-Cut
//
//  Created by andrewoch on 03.02.2023.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: Clapper_Rough_CutDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(Clapper_Rough_CutDocument()))
    }
}
