import Foundation
import Combine
import UserDefaultsWrapper
import UserDefaultsObjectCoder

private extension Stored {
    init(wrappedValue: Value, _ key: String, shouldEncrypt: Bool) {
        let prefix = Preferences.encryptionPrefix
        let actualKey = shouldEncrypt ? prefix + key : key
        self.init(wrappedValue: wrappedValue, actualKey)
    }
}

extension Preferences {
    static let symmetricKey: String = String(repeating: "A", count: 32)
    static let encryptionPrefix: String = "encrypted_"
}

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
    
    @Stored("greeting", shouldEncrypt: true)
    var greeting: String = "Hello"
    
    @Stored("updatedDate")
    var updatedDate: Date?
    
    static let standard: Preferences = .init(
        store: UserDefaultsStore(
            defaults: .standard,
            valueCoder: CryptoValueCoderDecorator(
                valueCoder: ObjectValueCoder(),
                symmetricKey: Preferences.symmetricKey,
                shouldEncrypt: { $0.hasPrefix(Preferences.encryptionPrefix) })))
    
    static let inMemory: Preferences = .init(store: InMemoryStore())
}

@dynamicMemberLookup
class PreferencesAccess: SettingsAccess {
    private let preferences: Preferences
    
    init(preferences: Preferences) {
        self.preferences = preferences
    }
    
    var objectWillChange: ObservableObjectPublisher {
        return preferences.objectWillChange
    }
    
    subscript<T: Codable>(dynamicMember keyPath: KeyPath<Settings, T>) -> T {
        return preferences[keyPath: keyPath]
    }
    
    subscript<T: Codable>(dynamicMember keyPath: ReferenceWritableKeyPath<Settings, T>) -> T {
        get { preferences[keyPath: keyPath] }
        set { preferences[keyPath: keyPath] = newValue }
    }
    
    func publisher<T: Codable>(for keyPath: KeyPath<Settings, T>) -> AnyPublisher<T, Never> {
        do {
            let concreteKeyPath = try preferences.keyPathConverted(fromProtocolKeyPath: keyPath)
            
            return try preferences.publisher(for: concreteKeyPath).eraseToAnyPublisher()
        } catch {
            preconditionFailure("\(error)")
        }
    }
}
