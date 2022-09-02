import Foundation
import SwiftUI
import Combine

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
