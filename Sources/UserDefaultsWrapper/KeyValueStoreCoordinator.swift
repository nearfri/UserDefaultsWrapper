import Foundation

open class KeyValueStoreCoordinator {
    let store: KeyValueStore
    var storageKeyPathsByWrappedKeyPath: [AnyKeyPath: AnyKeyPath] = [:]
    
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
}
