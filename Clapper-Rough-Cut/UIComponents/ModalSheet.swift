import SwiftUI

struct ModalSheet<Content: View, ActionBarContent: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @State var closeAction: () -> Void
    @State var title: String
    @State var minWidth: CGFloat
    @State var idealWidth: CGFloat
    @State var maxWidth: CGFloat
    @State var minHeight: CGFloat
    @State var idealHeight: CGFloat
    @State var maxHeight: CGFloat
    @State var resizableVertical: Bool
    let content: Content
    let actionBarContent: ActionBarContent

    private let cornerImageSize: CGFloat = 20
    private let closeButtonSize: CGFloat = 16

    init(
        title: String = .empty,
        minWidth: CGFloat = 500,
        idealWidth: CGFloat = 500,
        maxWidth: CGFloat = .infinity,
        minHeight: CGFloat = 500,
        idealHeight: CGFloat = 500,
        maxHeight: CGFloat = .infinity,
        resizableVertical: Bool = false,
        @ViewBuilder content: () -> Content,
        @ViewBuilder actionBarContent: () -> ActionBarContent = { EmptyView() },
        closeAction: @escaping () -> Void = {}
    ) {
        self._closeAction = State(initialValue: closeAction)
        self._title = State(initialValue: title)
        self._minWidth = State(initialValue: minWidth)
        self._idealWidth = State(initialValue: idealWidth)
        self._maxWidth = State(initialValue: maxWidth)
        self._minHeight = State(initialValue: minHeight)
        self._idealHeight = State(initialValue: idealHeight)
        self._maxHeight = State(initialValue: maxHeight)
        self._resizableVertical = State(initialValue: resizableVertical)
        self.content = content()
        self.actionBarContent = actionBarContent()
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top) {
                SystemImage.plus.imageView
                    .resizable()
                    .scaledToFit()
                    .frame(width: cornerImageSize, height: cornerImageSize)
                    .foregroundColor(.surfaceTertiary(colorScheme))
                Spacer()
                CustomLabel<Header2Style>(text: title)
                    .foregroundColor(.contentPrimary(colorScheme))
                Spacer()
                Button(action: closeAction) {
                    SystemImage.xmark.imageView
                        .resizable()
                        .scaledToFit()
                        .frame(width: closeButtonSize, height: closeButtonSize)
                        .foregroundColor(.contentPrimary(colorScheme))
                }.buttonStyle(PlainButtonStyle())
                    .focusable(false)
            }
            content
                .padding(.horizontal, 20)
            HStack(alignment: .bottom) {
                SystemImage.plus.imageView
                    .resizable()
                    .scaledToFit()
                    .frame(width: cornerImageSize, height: cornerImageSize)
                    .foregroundColor(.surfaceTertiary(colorScheme))
                Spacer()
                actionBarContent
                Spacer()
                SystemImage.plus.imageView
                    .resizable()
                    .scaledToFit()
                    .frame(width: cornerImageSize, height: cornerImageSize)
                    .foregroundColor(.surfaceTertiary(colorScheme))
            }
        }
        .padding()
        .frame(minWidth: minWidth, idealWidth: idealWidth, maxWidth: maxWidth)
        .frame(minHeight: resizableVertical ? minHeight : nil,
               idealHeight: resizableVertical ? idealHeight : nil,
               maxHeight: resizableVertical ? maxHeight : nil)
        .background(Color.surfaceSecondary(colorScheme))
        .cornerRadius(10)
    }
}
