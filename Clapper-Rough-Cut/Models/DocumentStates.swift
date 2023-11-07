import SwiftUI

struct DocumentStates {
    var isExportViewPresented: Bool = false
    var isCharactersViewPresented: Bool = false
    var selectedHeaderOption: HeaderMenuOption = .none
    var popupPositions: [UUID: (Binding<Bool>, AnyView)] = [:]
}
