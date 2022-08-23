import Foundation
import Combine

#if os(iOS) || os(macOS) || os(tvOS)

public class UbiquitousStore: KeyValueStore {
    public let store: NSUbiquitousKeyValueStore
    public let valueCoder: ValueCoder
    
    private let storeObserver: UbiquitousStoreObserver
    private let didChange: PassthroughSubject<String, Never> = .init()
    
    public init(store: NSUbiquitousKeyValueStore = .default, valueCoder: ValueCoder) {
        self.store = store
        self.valueCoder = valueCoder
        self.storeObserver = UbiquitousStoreObserver(store: store)
    }
    
    public func value<T: Codable>(forKey key: String, ofType type: T.Type) throws -> T? {
        storeObserver.addObservation(forKey: key)
        
        guard let encodedValue = store.object(forKey: key) else { return nil }
        return try valueCoder.decode(type, from: encodedValue, forKey: key)
    }
    
    public func setValue<T: Codable>(_ value: T, forKey key: String) throws {
        storeObserver.addObservation(forKey: key)
        
        let encodedValue = try valueCoder.encode(value, forKey: key)
        store.set(encodedValue, forKey: key)
        
        didChange.send(key)
    }
    
    public func hasValue(forKey key: String) -> Bool {
        return store.object(forKey: key) != nil
    }
    
    public func removeValue(forKey key: String) {
        storeObserver.addObservation(forKey: key)
        
        store.removeObject(forKey: key)
        
        didChange.send(key)
    }
    
    @discardableResult
    public func synchronize() -> Bool {
        return store.synchronize()
    }
    
    public var objectDidChange: AnyPublisher<String, Never> {
        return didChange.merge(with: storeObserver.objectDidChange).eraseToAnyPublisher()
    }
}

private class UbiquitousStoreObserver {
    private let store: NSUbiquitousKeyValueStore
    private let didChange: PassthroughSubject<String, Never> = .init()
    
    private var keys: Set<String> = []
    
    private var subscriptions: Set<AnyCancellable> = []
    
    init(store: NSUbiquitousKeyValueStore) {
        self.store = store
        
        let notificationName = NSUbiquitousKeyValueStore.didChangeExternallyNotification
        NotificationCenter.default
            .publisher(for: notificationName, object: store)
            .sink { [weak self] notification in
                self?.didChangeExternally(notification)
            }
            .store(in: &subscriptions)
    }
    
    var objectDidChange: AnyPublisher<String, Never> {
        return didChange.eraseToAnyPublisher()
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
        filteredKeys.forEach({ didChange.send($0) })
    }
}

#endif
