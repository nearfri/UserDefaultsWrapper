import Foundation
import SwiftUI

private struct SettingsKey: EnvironmentKey {
    static let defaultValue: Settings = InMemorySettings()
}

extension EnvironmentValues {
    var appSettings: Settings {
        get { self[SettingsKey.self] }
        set { self[SettingsKey.self] = newValue }
    }
}
