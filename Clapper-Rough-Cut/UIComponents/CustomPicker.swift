import SwiftUI

struct CustomPicker: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selectedOption: Int
    @State var options: [SystemImage]

    var body: some View {
        Picker(String.empty, selection: $selectedOption) {
            ForEach(0..<options.count, id: \.self) { index in
                options[index].imageView
                    .foregroundColor(index == selectedOption ? Color.contentPrimary(colorScheme) : Color.contentSecondary(colorScheme))
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.contentPrimary(colorScheme), lineWidth: 1)
                    )
                    .padding(4)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}
