import SwiftUI

struct DoubleTapGestureModifier: ViewModifier {
    var action: () -> Void

    func body(content: Content) -> some View {
        content.gesture(
            TapGesture(count: 2)
                .onEnded { _ in
                    self.action()
                }
        )
    }
}

extension View {
    func onDoubleTapGesture(_ action: @escaping () -> Void) -> some View {
        self.modifier(DoubleTapGestureModifier(action: action))
    }
}
