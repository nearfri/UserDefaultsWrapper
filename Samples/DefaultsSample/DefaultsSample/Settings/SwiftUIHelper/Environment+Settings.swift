import Foundation
import SwiftUI

private struct SettingsKey: EnvironmentKey {
    static let defaultValue: FontSettings = InMemorySettings()
}

extension EnvironmentValues {
    var fontSettings: FontSettings {
        get { self[SettingsKey.self] }
        set { self[SettingsKey.self] = newValue }
    }
}
