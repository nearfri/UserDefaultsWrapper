import Foundation
import SwiftUI
import Combine

@propertyWrapper
struct AppSetting<T: Codable>: DynamicProperty {
    private let keyPath: ReferenceWritableKeyPath<Settings, T>
    
    @Environment(\.appSettings)
    private var settings: SettingsAccess
    
    @StateObject
    private var observer: SettingsObserver = .init()
    
    init(_ keyPath: ReferenceWritableKeyPath<Settings, T>) {
        self.keyPath = keyPath
    }
    
    var wrappedValue: T {
        get { settings[dynamicMember: keyPath] }
        nonmutating set { settings[dynamicMember: keyPath] = newValue }
    }
    
    var projectedValue: Binding<T> {
        Binding(get: {
            settings[dynamicMember: keyPath]
        }, set: { newValue in
            settings[dynamicMember: keyPath] = newValue
        })
    }
    
    mutating func update() {
        observer.observe(keyPath, from: settings)
    }
}

private extension AppSetting {
    class SettingsObserver: ObservableObject {
        private var settings: SettingsAccess?
        
        private var subscription: AnyCancellable?
        
        func observe(_ keyPath: KeyPath<Settings, T>, from settings: SettingsAccess) {
            if self.settings === settings { return }
            
            self.settings = settings
            
            subscription = settings.publisher(for: keyPath).sink { [weak self] in
                self?.objectWillChange.send()
            }
        }
    }
}