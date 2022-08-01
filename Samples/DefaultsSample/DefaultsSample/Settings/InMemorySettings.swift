import Foundation
import Combine

class InMemorySettings: Settings {
    var isBold: Bool = false
    var isItalic: Bool = false
    var isUnderline: Bool = false
    var isStrikethrough: Bool = false
    
    var greeting: String = "hello"
    
    var updatedDate: Date?
}

class InMemorySettingsAccess: SettingsAccess {
    private let settings: InMemorySettings
    private let subject: PassthroughSubject<AnyKeyPath, Never> = .init()
    
    init(settings: InMemorySettings = .init()) {
        self.settings = settings
    }
    
    subscript<T: Codable>(dynamicMember keyPath: KeyPath<Settings, T>) -> T {
        return settings[keyPath: keyPath]
    }
    
    subscript<T: Codable>(dynamicMember keyPath: ReferenceWritableKeyPath<Settings, T>) -> T {
        get {
            return settings[keyPath: keyPath]
        }
        set {
            subject.send(keyPath)
            settings[keyPath: keyPath] = newValue
        }
    }
    
    func publisher<T: Codable>(for keyPath: KeyPath<Settings, T>) -> AnyPublisher<Void, Never> {
        return subject.filter({ $0 == keyPath }).map({ _ in () }).eraseToAnyPublisher()
    }
}
