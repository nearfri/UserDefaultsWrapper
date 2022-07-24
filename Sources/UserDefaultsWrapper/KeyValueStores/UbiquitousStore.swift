import Foundation
import Combine

#if os(iOS) || os(macOS) || os(tvOS)

public class UbiquitousStore: KeyValueStore {
    public let store: NSUbiquitousKeyValueStore
    public let valueCoder: ValueCoder
    
    private let cache: KeyValueStore = InMemoryStore()
    
    private let storeObserver: UbiquitousStoreObserver
    private let willChange: PassthroughSubject<String, Never> = .init()
    private let didChange: PassthroughSubject<String, Never> = .init()
    
    public init(store: NSUbiquitousKeyValueStore = .default, valueCoder: ValueCoder) {
        self.store = store
        self.valueCoder = valueCoder
        self.storeObserver = UbiquitousStoreObserver(store: store, cache: cache)
    }
    
    public func value<T: Codable>(forKey key: String, ofType type: T.Type) throws -> T? {
        if let cachedValue = try cache.value(forKey: key, ofType: type) {
            return cachedValue
        }
        
        storeObserver.addObservation(forKey: key)
        
        guard let encodedValue = store.object(forKey: key) else {
            try? cache.setValue(nil as T?, forKey: key)
            return nil
        }
        
        let result = try valueCoder.decode(type, from: encodedValue)
        
        try? cache.setValue(result, forKey: key)
        
        return result
    }
    
    private func addObservation<T: Codable>(forKey key: String, ofType type: T.Type) {
        if storeObserver.hasObservation(forKey: key) { return }
        
        _ = try? value(forKey: key, ofType: type)
    }
    
    public func setValue<T: Codable>(_ value: T, forKey key: String) throws {
        let encodedValue = try valueCoder.encode(value)
        
        addObservation(forKey: key, ofType: T.self)
        
        willChange.send(key)
        
        store.set(encodedValue, forKey: key)
        
        try? cache.setValue(value, forKey: key)
        
        didChange.send(key)
    }
    
    public func removeValue(forKey key: String) {
        willChange.send(key)
        
        store.removeObject(forKey: key)
        cache.removeValue(forKey: key)
        
        didChange.send(key)
    }
    
    @discardableResult
    public func synchronize() -> Bool {
        return store.synchronize()
    }
    
    public var objectWillChange: AnyPublisher<String, Never> {
        return willChange.merge(with: storeObserver.objectWillChange).eraseToAnyPublisher()
    }
    
    public var objectDidChange: AnyPublisher<String, Never> {
        return didChange.merge(with: storeObserver.objectDidChange).eraseToAnyPublisher()
    }
}

private class UbiquitousStoreObserver {
    private let store: NSUbiquitousKeyValueStore
    private let cache: KeyValueStore
    private let willChange: PassthroughSubject<String, Never> = .init()
    private let didChange: PassthroughSubject<String, Never> = .init()
    
    private var keys: Set<String> = []
    
    private var subscriptions: Set<AnyCancellable> = []
    
    init(store: NSUbiquitousKeyValueStore, cache: KeyValueStore) {
        self.store = store
        self.cache = cache
        
        let notificationName = NSUbiquitousKeyValueStore.didChangeExternallyNotification
        NotificationCenter.default
            .publisher(for: notificationName, object: store)
            .sink { [weak self] notification in
                self?.didChangeExternally(notification)
            }
            .store(in: &subscriptions)
    }
    
    var objectWillChange: AnyPublisher<String, Never> {
        return willChange.eraseToAnyPublisher()
    }
    
    var objectDidChange: AnyPublisher<String, Never> {
        return didChange.eraseToAnyPublisher()
    }
    
    func hasObservation(forKey key: String) -> Bool {
        return keys.contains(key)
    }
    
    func addObservation(forKey key: String) {
        keys.insert(key)
    }
    
    private func didChangeExternally(_ notification: Notification) {
        let changedKeysKey = NSUbiquitousKeyValueStoreChangedKeysKey
        let changedKeys = notification.userInfo?[changedKeysKey] as? [String]
        notifyOfChanges(forKeys: changedKeys)
    }
    
    private func notifyOfChanges(forKeys keys: [String]?) {
        let filteredKeys = keys.map({ self.keys.intersection($0) }) ?? self.keys
        filteredKeys.forEach({ notifyOfChange(forKey: $0) })
    }
    
    private func notifyOfChange(forKey key: String) {
        willChange.send(key)
        cache.removeValue(forKey: key)
        didChange.send(key)
    }
}

#endif
