import SwiftUI

struct CustomPicker: View {
    
    @Binding var selectedOption: Int
    @State var options: [SystemImage]

    var body: some View {
        Picker(String.empty, selection: $selectedOption) {
            ForEach(0..<options.count, id: \.self) { index in
                options[index].imageView
                    .foregroundColor(index == selectedOption ? Asset.contentPrimary.swiftUIColor : Asset.contentSecondary.swiftUIColor)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Asset.contentPrimary.swiftUIColor, lineWidth: 1)
                    )
                    .padding(4)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}
