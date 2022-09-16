import Foundation
import SwiftUI
import Combine

public protocol SettingsBridge {
    associatedtype Settings
    // associatedtype Settings: AnyObject // Compile Error
    
    static var environmentKeyPath: KeyPath<EnvironmentValues, Settings> { get }
    
    static func publisher<T: Codable>(
        for keyPath: KeyPath<Settings, T>,
        of settings: Settings
    ) -> AnyPublisher<T, Never>
}

@propertyWrapper
public struct AppSetting<Bridge: SettingsBridge, T: Codable>: DynamicProperty {
    private let keyPath: ReferenceWritableKeyPath<Bridge.Settings, T>
    
    @Environment(Bridge.environmentKeyPath)
    private var settings: Bridge.Settings
    
    @StateObject
    private var observer: SettingsObserver = .init()
    
    public init(_ keyPath: ReferenceWritableKeyPath<Bridge.Settings, T>) {
        self.keyPath = keyPath
    }
    
    public var wrappedValue: T {
        get { settings[keyPath: keyPath] }
        nonmutating set { settings[keyPath: keyPath] = newValue }
    }
    
    public var projectedValue: Binding<T> {
        return Binding(
            get: { settings[keyPath: keyPath] },
            set: { settings[keyPath: keyPath] = $0 }
        )
    }
    
    public mutating func update() {
        observer.observe(keyPath, of: settings)
    }
}

extension AppSetting {
    class SettingsObserver: ObservableObject {
        private var settings: Bridge.Settings?
        
        private var subscription: AnyCancellable?
        
        func observe(_ keyPath: KeyPath<Bridge.Settings, T>, of settings: Bridge.Settings) {
            if (self.settings as AnyObject) === (settings as AnyObject) { return }
            
            self.settings = settings
            
            var isReadyToReceive = false
            defer { isReadyToReceive = true }
            
            subscription = Bridge.publisher(for: keyPath, of: settings)
                .drop(while: { _ in !isReadyToReceive })
                .sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
        }
    }
}
