import Foundation
import Combine

extension KeyValueStoreCoordinator {
    public enum KeyPathError: Error {
        case invalidKeyPath
        case typeMismatch
    }
}

open class KeyValueStoreCoordinator: ObservableObject {
    public typealias ObjectWillChangePublisher = ObservableObjectPublisher
    
    let store: KeyValueStore
    
    private var storageKeyPathsByWrappedKeyPath: [AnyKeyPath: AnyKeyPath] = [:]
    
    var lastAccessedWrappedKeyPath: AnyKeyPath?
    
    private var subscriptions: Set<AnyCancellable> = []
    
    public init(store: KeyValueStore) {
        self.store = store
        
        setupStorages()
    }
    
    private func setupStorages() {
        for child in Mirror(reflecting: self).children {
            guard let storage = child.value as? ConfigurableWithCoordinator else { continue }
            storage.setup(with: self)
        }
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
        if storageKeyPathsByWrappedKeyPath[wrappedKeyPath] == nil {
            // Register the storageKeyPath by accessing the value
            _ = self[keyPath: wrappedKeyPath]
        }
        
        return storageKeyPathsByWrappedKeyPath[wrappedKeyPath]
    }
    
    func registerStoragePublisher<P, T>(
        _ publisher: P
    ) where P: Publisher, P.Output == T, P.Failure == Never {
        publisher.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        .store(in: &subscriptions)
    }
    
    func wrappedKeyPathConverted(fromProtocolKeyPath protocolKeyPath: AnyKeyPath) -> AnyKeyPath? {
        var result: AnyKeyPath?
        
        _ = self[keyPath: protocolKeyPath]
        result = lastAccessedWrappedKeyPath
        
        return result
    }
}

private protocol ConfigurableWithCoordinator {
    func setup(with storeCoordinator: KeyValueStoreCoordinator)
}

extension Stored: ConfigurableWithCoordinator {}
