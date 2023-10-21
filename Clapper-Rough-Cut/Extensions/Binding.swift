import SwiftUI

extension Binding {
    static func getOnly(_ value: Value) -> Binding<Value> {
        return Binding(get: { value }, set: { _ in })
    }
}
