import Foundation
import SwiftUI

private struct SettingsAccessKey: EnvironmentKey {
    static let defaultValue: SettingsAccess = InMemorySettingsAccess()
}

extension EnvironmentValues {
    var appSettings: SettingsAccess {
        get { self[SettingsAccessKey.self] }
        set { self[SettingsAccessKey.self] = newValue }
    }
}
