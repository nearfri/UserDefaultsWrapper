import Foundation
import Combine

public protocol KeyValueLookup: AnyObject {
    func publisher<T: Codable>(for keyPath: KeyPath<Self, T>) throws -> Stored<T>.Publisher
    
    func keyPathConverted<T: Codable>(
        fromProtocolKeyPath protocolKeyPath: AnyKeyPath, valueType: T.Type
    ) throws -> KeyPath<Self, T>
    
    func key<T: Codable>(for keyPath: KeyPath<Self, T>) throws -> String
    
    func storedValue<T: Codable>(for keyPath: KeyPath<Self, T>) throws -> T?
    
    func hasStoredValue<T: Codable>(for keyPath: KeyPath<Self, T>) -> Bool
    
    func removeStoredValue<T: Codable>(for keyPath: KeyPath<Self, T>)
    
    func removeAllStoredValues()
}

extension KeyValueLookup where Self: KeyValueStoreCoordinator {
    public func publisher<T: Codable>(for keyPath: KeyPath<Self, T>) throws -> Stored<T>.Publisher {
        return try Stored<T>.publisher(instance: self, storageKeyPath: storageKeyPath(for: keyPath))
    }
    
    // Compile error - Type 'Self' constrained to non-protocol, non-class type 'P'
//    public func keyPathConverted<P, T: Codable>(
//        fromProtocolKeyPath protocolKeyPath: KeyPath<P, T>
//    ) throws -> KeyPath<Self, T> where Self: P {}
    
    public func keyPathConverted<T: Codable>(
        fromProtocolKeyPath protocolKeyPath: AnyKeyPath, valueType: T.Type
    ) throws -> KeyPath<Self, T> {
        precondition(type(of: protocolKeyPath).valueType == valueType)
        
        switch wrappedKeyPathConverted(fromProtocolKeyPath: protocolKeyPath) {
        case let result as KeyPath<Self, T>:
            return result
        case _?:
            throw KeyValueStoreCoordinator.KeyPathError.typeMismatch
        case nil:
            throw KeyValueStoreCoordinator.KeyPathError.invalidKeyPath
        }
    }
    
    public func key<T: Codable>(for keyPath: KeyPath<Self, T>) throws -> String {
        return try self[keyPath: storageKeyPath(for: keyPath)].key
    }
    
    private func storageKeyPath<T: Codable>(
        for keyPath: KeyPath<Self, T>
    ) throws -> KeyPath<Self, Stored<T>> {
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
