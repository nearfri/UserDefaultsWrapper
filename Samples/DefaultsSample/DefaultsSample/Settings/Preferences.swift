import Foundation
import Combine
import UserDefaultsWrapper
import UserDefaultsWrapperPlus

final class Preferences: KeyValueStoreCoordinator, KeyValueLookup, Settings {
    @Stored("isBold")
    var isBold: Bool = false
    
    @Stored("isItalic")
    var isItalic: Bool = false
    
    @Stored("isUnderline")
    var isUnderline: Bool = false
    
    @Stored("isStrikethrough")
    var isStrikethrough: Bool = false
    
    @Stored("age")
    var age: Int = 30
    
    @Stored("greeting")
    var greeting: String = "hello"
    
    @Stored("updatedDate")
    var updatedDate: Date?
    
    static let standard: Preferences = .init(
        store: UserDefaultsStore(
            defaults: .standard,
            valueCoder: ObjectValueCoder()))
    
    #if DEBUG
    static let inMemory: Preferences = .init(store: InMemoryStore())
    #endif
}

class PreferencesAccess: SettingsAccess {
    private let preferences: Preferences
    
    init(preferences: Preferences) {
        self.preferences = preferences
    }
    
    subscript<T: Codable>(dynamicMember keyPath: KeyPath<Settings, T>) -> T {
        return preferences[keyPath: keyPath]
    }
    
    subscript<T: Codable>(dynamicMember keyPath: ReferenceWritableKeyPath<Settings, T>) -> T {
        get {
            return preferences[keyPath: keyPath]
        }
        set {
            preferences[keyPath: keyPath] = newValue
        }
    }
    
    func publisher<T: Codable>(for keyPath: KeyPath<Settings, T>) -> AnyPublisher<T, Never> {
        do {
            let concreteKeyPath = try preferences.keyPathConverted(
                fromProtocolKeyPath: keyPath,
                valueType: T.self)
            
            return try preferences.publisher(for: concreteKeyPath).eraseToAnyPublisher()
        } catch {
            preconditionFailure("\(error)")
        }
    }
}
