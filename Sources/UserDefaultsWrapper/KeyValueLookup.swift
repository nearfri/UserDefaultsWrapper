import Foundation
import Combine

public protocol KeyValueLookup: AnyObject {
    func key<T: Codable>(for keyPath: KeyPath<Self, T>) -> String
    
    func publisher<T: Codable>(for keyPath: KeyPath<Self, T>) -> AnyPublisher<T, Never>
    
    func storedValue<T: Codable>(for keyPath: KeyPath<Self, T>) throws -> T?
    
    func hasStoredValue<T: Codable>(for keyPath: KeyPath<Self, T>) -> Bool
    
    func removeStoredValue<T: Codable>(for keyPath: KeyPath<Self, T>)
    
    func removeAllStoredValues()
}

extension KeyValueLookup where Self: KeyValueStoreCoordinator {
    public func key<T: Codable>(for keyPath: KeyPath<Self, T>) -> String {
        return self[keyPath: storageKeyPath(for: keyPath)].key
    }
    
    private func storageKeyPath<T: Codable>(
        for keyPath: KeyPath<Self, T>
    ) -> KeyPath<Self, Stored<T>> {
        // coordinator에 storageKeyPath(forWrappedKeyPath: AnyKeyPath) -> AnyKeyPath 추가하는게 나을 듯
        if storageKeyPathsByWrappedKeyPath[keyPath] == nil {
            _ = self[keyPath: keyPath]
        }
        
        return storageKeyPathsByWrappedKeyPath[keyPath] as! KeyPath<Self, Stored<T>>
    }
    
    public func unsafePublisher<P, T: Codable>(
        for keyPath: KeyPath<P, T>
    ) -> AnyPublisher<T, Never> /* where Self: P */ {
        precondition(self is P)
        
        // coordinator에 unsafeConcreteKeyPath(forProtocolKeyPath:) -> AnyKeyPath 추가해도 될 듯
//        let selfAsP = self as! P
//        
//        lastAccessedKeyPath = nil // lastAccessedWrappedKeyPath or lastAccessedStorageKeyPath
//        _ = selfAsP[keyPath: keyPath]
//        let wrappedKeyPath = lastAccessedKeyPath as! KeyPath<Self, T>
//        return publisher(for: wrappedKeyPath)
        
        fatalError()
    }
    
    public func publisher<T: Codable>(for keyPath: KeyPath<Self, T>) -> AnyPublisher<T, Never> {
        let wrapper = self[keyPath: storageKeyPath(for: keyPath)]
        print(wrapper)
        // TODO: wrapper와 store를 이용해 publisher 생성
        fatalError()
    }
    
    public func storedValue<T: Codable>(for keyPath: KeyPath<Self, T>) throws -> T? {
        return try store.value(forKey: key(for: keyPath), ofType: T.self)
    }
    
    public func hasStoredValue<T: Codable>(for keyPath: KeyPath<Self, T>) -> Bool {
        do {
            return try storedValue(for: keyPath) != nil
        } catch {
            return true
        }
    }
    
    public func removeStoredValue<T: Codable>(for keyPath: KeyPath<Self, T>) {
        store.removeValue(forKey: key(for: keyPath))
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
