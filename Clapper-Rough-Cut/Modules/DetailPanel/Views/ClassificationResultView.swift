import SwiftUI

struct ClassificationResultView: View {
    var elements: [ClassificationElement]
    let spacing: CGFloat = 4
    let lineSpacing: CGFloat = 4

    @State private var totalHeight = CGFloat.zero

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.content(in: geometry)
            }
        }
        .frame(height: totalHeight)
    }

    private func content(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(self.elements.sorted(by: { $0.confidence > $1.confidence }), id: \.className) { element in
                self.item(for: element)
                    .padding([.horizontal, .vertical], spacing)
                    .alignmentGuide(.leading) { d in
                        if (abs(width - d.width) > geometry.size.width) {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if element == self.elements.last! {
                            width = 0
                        } else {
                            width -= d.width
                        }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if element == self.elements.last! {
                            height = 0
                        }
                        return result
                    }
            }
        }
        .background(viewHeightReader($totalHeight))
    }

    private func item(for element: ClassificationElement) -> some View {
        HStack {
            Text(element.className)
                .lineLimit(1)
                .foregroundColor(Asset.contentPrimary.swiftUIColor)
            Text(String(format: "%.2f", element.confidence))
                .lineLimit(1)
                .foregroundColor(Asset.surfacePrimary.swiftUIColor)
        }
        .padding(5)
        .background(Asset.surfaceTertiary.swiftUIColor)
        .cornerRadius(5)
    }

    private func viewHeightReader(_ height: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let frame = geometry.frame(in: .local)
            DispatchQueue.main.async {
                height.wrappedValue = frame.size.height
            }
            return .clear
        }
    }
}
