import SwiftUI

struct PopupPositionModifier: ViewModifier {
    @EnvironmentObject var document: ClapperRoughCutDocument
    @State var id: UUID
    @Binding var condition: Bool
    var content: () -> any View

    func body(content: Content) -> some View {
        content.background(GeometryReader { buttonGeometry in
            Color.clear
                .onAppear {
                    let buttonFrame = buttonGeometry.frame(in: .global)
                    let view = AnyView(OverlayMenu(position: CGPoint(x: buttonFrame.minX, y: buttonFrame.maxY / 2)) {
                        content
                    })
                    document.states.popupPositions[id] = ($condition, view)
                }
        })
    }
}

extension View {
    func popup(id: UUID, condition: Binding<Bool>, @ViewBuilder content: @escaping () -> any View) -> some View { // Use "any View" here as well
        modifier(PopupPositionModifier(id: id, condition: condition, content: content))
    }
}
