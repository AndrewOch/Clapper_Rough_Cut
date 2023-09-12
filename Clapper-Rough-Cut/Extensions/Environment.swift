import SwiftUI

struct SelectedHeaderOptionKey: EnvironmentKey {
    static let defaultValue: HeaderMenuOption = .none
}

extension EnvironmentValues {
    var selectedHeaderOption: HeaderMenuOption {
        get { self[SelectedHeaderOptionKey.self] }
        set { self[SelectedHeaderOptionKey.self] = newValue }
    }
}
