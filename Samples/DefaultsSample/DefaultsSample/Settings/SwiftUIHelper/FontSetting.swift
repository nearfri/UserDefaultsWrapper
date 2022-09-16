import Foundation
import SwiftUI
import Combine
import UserDefaultsWrapper

typealias FontSetting<T: Codable> = AppSetting<FontSettingsBridge, T>

struct FontSettingsBridge: SettingsBridge {
    typealias Settings = FontSettings
    
    static var environmentKeyPath: KeyPath<EnvironmentValues, Settings> {
        return \.fontSettings
    }
    
    static func publisher<T: Codable>(
        for keyPath: KeyPath<Settings, T>,
        of settings: Settings
    ) -> AnyPublisher<T, Never> {
        return settings.publisher(for: keyPath)
    }
}

// MARK: -

private struct FontSettingsKey: EnvironmentKey {
    static let defaultValue: FontSettings = InMemorySettings()
}

extension EnvironmentValues {
    var fontSettings: FontSettings {
        get { self[FontSettingsKey.self] }
        set { self[FontSettingsKey.self] = newValue }
    }
}
