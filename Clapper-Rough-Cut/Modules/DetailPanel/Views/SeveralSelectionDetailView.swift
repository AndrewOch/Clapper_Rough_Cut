import SwiftUI

struct SeveralSelectionDetailView: View {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @Binding var selection: Set<FileSystemElement.ID>
    @State private var isModalPresented = false

    var body: some View {
        EmptyView()
    }
}
