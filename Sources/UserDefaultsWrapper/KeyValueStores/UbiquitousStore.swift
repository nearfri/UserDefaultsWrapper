import Foundation

#if os(iOS) || os(macOS) || os(tvOS)

public class UbiquitousStore: KeyValueStore {
    public let store: NSUbiquitousKeyValueStore
    public let valueCoder: ValueCoder
    
    public init(store: NSUbiquitousKeyValueStore = .default, valueCoder: ValueCoder) {
        self.store = store
        self.valueCoder = valueCoder
    }
    
    public func value<T: Codable>(forKey key: String, ofType type: T.Type) throws -> T? {
        guard let encodedValue = store.object(forKey: key) else { return nil }
        return try valueCoder.decode(type, from: encodedValue)
    }
    
    public func setValue<T: Codable>(_ value: T, forKey key: String) throws {
        let encodedValue = try valueCoder.encode(value)
        store.set(encodedValue, forKey: key)
    }
    
    public func removeValue(forKey key: String) {
        store.removeObject(forKey: key)
    }
    
    @discardableResult
    public func synchronize() -> Bool {
        return store.synchronize()
    }
}

#endif
