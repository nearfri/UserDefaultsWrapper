import Foundation
import Combine

public protocol KeyValueLookup: AnyObject {
    func key<T: Codable>(for keyPath: KeyPath<Self, T>) throws -> String
    
    func storedValue<T: Codable>(for keyPath: KeyPath<Self, T>) throws -> T?
    
    func hasStoredValue<T: Codable>(for keyPath: KeyPath<Self, T>) -> Bool
    
    func removeStoredValue<T: Codable>(for keyPath: KeyPath<Self, T>)
    
    func removeAllStoredValues()
}

extension KeyValueLookup where Self: KeyValueStoreCoordinator {
    public func key<T: Codable>(for keyPath: KeyPath<Self, T>) throws -> String {
        return try self[keyPath: storageKeyPath(for: keyPath)].key
    }
    
    private func storageKeyPath<T: Codable>(
        for keyPath: KeyPath<Self, T>
    ) throws -> KeyPath<Self, Stored<T>> {
        if storageKeyPath(forWrappedKeyPath: keyPath) == nil {
            // Register the keyPath by accessing the value
            _ = self[keyPath: keyPath]
        }
        
        switch storageKeyPath(forWrappedKeyPath: keyPath) {
        case let result as KeyPath<Self, Stored<T>>:
            return result
        case _?:
            throw KeyValueStoreCoordinator.KeyPathError.typeMismatch
        case nil:
            throw KeyValueStoreCoordinator.KeyPathError.invalidKeyPath
        }
    }
    
    public func storedValue<T: Codable>(for keyPath: KeyPath<Self, T>) throws -> T? {
        return try store.value(forKey: key(for: keyPath), ofType: T.self)
    }
    
    public func hasStoredValue<T: Codable>(for keyPath: KeyPath<Self, T>) -> Bool {
        do {
            return try storedValue(for: keyPath) != nil
        } catch {
            return false
        }
    }
    
    public func removeStoredValue<T: Codable>(for keyPath: KeyPath<Self, T>) {
        try? store.removeValue(forKey: key(for: keyPath))
    }
    
    public func removeAllStoredValues() {
        for child in Mirror(reflecting: self).children {
            guard let storage = child.value as? StoreKeyProviding else { continue }
            store.removeValue(forKey: storage.key)
        }
    }
}

private protocol StoreKeyProviding {
    var key: String { get }
}

extension Stored: StoreKeyProviding {}
