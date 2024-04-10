import SwiftUI

struct OverlayMenu<Content: View>: View {
    
    @State var position: CGPoint
    private let content: Content

    @State private var frame: CGRect = CGRect()

    init(position: CGPoint,
         @ViewBuilder content: () -> Content) {
        self._position = State(initialValue: position)
        self.content = content()
    }

    var body: some View {
        content
            .background(Asset.surfaceSecondary.swiftUIColor)
            .background(GeometryReader { buttonGeometry in
                Color.clear
                    .onAppear {
                        self.frame = buttonGeometry.frame(in: .global)
                    }
            })
            .cornerRadius(10)
            .shadow(color: Asset.tertiary.swiftUIColor.opacity(0.2),
                    radius: 10,
                    y: 10)
            .position(x: position.x, y: position.y)
            .offset(x: frame.width * 0.5, y: frame.height * 0.5)
    }
}
