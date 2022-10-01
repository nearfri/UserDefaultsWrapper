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

final class Preferences: KeyValueStoreCoordinator, KeyValueLookup {
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
    
    static let inMemory: Preferences = .init(store: InMemoryStore())
    
    static let standard: Preferences = {
        Preferences.migrateStore()
        
        return Preferences(
            store: UserDefaultsStore(
                defaults: .standard,
                valueCoder: CryptoValueCoderDecorator(
                    valueCoder: ObjectValueCoder(),
                    symmetricKey: Preferences.symmetricKey,
                    encryptWhere: { $0.hasPrefix(Preferences.encryptionPrefix) })))
    }()
    
    private static func migrateStore() {
        // Migrate data if needed
    }
    
    private func publisher<P, T: Codable>(
        forProtocolKeyPath keyPath: KeyPath<P, T>
    ) -> AnyPublisher<T, Never> {
        do {
            let concreteKeyPath = try keyPathConverted(fromProtocolKeyPath: keyPath)
            
            return try publisher(for: concreteKeyPath).eraseToAnyPublisher()
        } catch {
            preconditionFailure("\(error)")
        }
    }
}

extension Preferences: FontSettings {
    func publisher<T: Codable>(for keyPath: KeyPath<FontSettings, T>) -> AnyPublisher<T, Never> {
        return publisher(forProtocolKeyPath: keyPath)
    }
}

extension Preferences: GreetingStore {
    func publisher<T: Codable>(for keyPath: KeyPath<GreetingStore, T>) -> AnyPublisher<T, Never> {
        return publisher(forProtocolKeyPath: keyPath)
    }
}
