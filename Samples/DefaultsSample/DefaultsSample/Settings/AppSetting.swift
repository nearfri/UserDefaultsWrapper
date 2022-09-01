import Foundation
import SwiftUI
import Combine

@propertyWrapper
struct AppSetting<T: Codable>: DynamicProperty {
    private let keyPath: ReferenceWritableKeyPath<Settings, T>
    
    @Environment(\.appSettings)
    private var settings: Settings
    
    @StateObject
    private var observer: SettingsObserver = .init()
    
    init(_ keyPath: ReferenceWritableKeyPath<Settings, T>) {
        self.keyPath = keyPath
    }
    
    var wrappedValue: T {
        get { settings[keyPath: keyPath] }
        nonmutating set { settings[keyPath: keyPath] = newValue }
    }
    
    var projectedValue: Binding<T> {
        return Binding(
            get: { settings[keyPath: keyPath] },
            set: { settings[keyPath: keyPath] = $0 }
        )
    }
    
    mutating func update() {
        observer.observe(keyPath, of: settings)
    }
}

private extension AppSetting {
    class SettingsObserver: ObservableObject {
        private var settings: Settings?
        
        private var subscription: AnyCancellable?
        
        func observe(_ keyPath: KeyPath<Settings, T>, of settings: Settings) {
            if self.settings === settings { return }
            
            self.settings = settings
            
            subscription = settings.publisher(for: keyPath).dropFirst().sink { [weak self] _ in
                self?.objectWillChange.send()
            }
        }
    }
}
