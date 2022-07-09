import Foundation

extension KeyValueStoreCoordinator {
    public enum KeyPathError: Error {
        case invalidKeyPath
        case typeMismatch
    }
}

open class KeyValueStoreCoordinator {
    let store: KeyValueStore
    private var storageKeyPathsByWrappedKeyPath: [AnyKeyPath: AnyKeyPath] = [:]
    
    public init(store: KeyValueStore) {
        self.store = store
    }
    
    @discardableResult
    public func synchronize() -> Bool {
        return store.synchronize()
    }
    
    func register(storageKeyPath: AnyKeyPath, forWrappedKeyPath wrappedKeyPath: AnyKeyPath) {
        if storageKeyPathsByWrappedKeyPath[wrappedKeyPath] == nil {
            storageKeyPathsByWrappedKeyPath[wrappedKeyPath] = storageKeyPath
        }
    }
    
    func storageKeyPath(forWrappedKeyPath wrappedKeyPath: AnyKeyPath) -> AnyKeyPath? {
        return storageKeyPathsByWrappedKeyPath[wrappedKeyPath]
    }
}
