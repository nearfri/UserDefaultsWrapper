import Foundation
import Combine
import UserDefaultsWrapperUtil

@propertyWrapper
public struct Stored<Value: Codable> {
    let key: String
    private let defaultValue: Value
    
    @Box
    private var cache: Cache?
    
    public init(wrappedValue: Value, _ key: String) {
        self.key = key
        self.defaultValue = wrappedValue
    }
    
    public init<OptionalWrapped>(_ key: String) where Value == OptionalWrapped? {
        self.init(wrappedValue: nil, key)
    }
    
    @available(*, unavailable, message: "@Stored can only be applied to KeyValueStoreCoordinator")
    public var wrappedValue: Value {
        get { preconditionFailure() }
        set { preconditionFailure() }
    }
    
    // https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-wrappers.md#referencing-the-enclosing-self-in-a-wrapper-type
    public static subscript<EnclosingType: KeyValueStoreCoordinator>(
        _enclosingInstance instance: EnclosingType,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingType, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingType, Self>
    ) -> Value {
        get {
            instance.register(storageKeyPath: storageKeyPath, forWrappedKeyPath: wrappedKeyPath)
            
            return cache(at: storageKeyPath, in: instance).value
        }
        set {
            let wrapper = instance[keyPath: storageKeyPath]
            let store = instance.store
            
            do {
                if isNilValue(newValue) && isNilValue(wrapper.defaultValue) {
                    store.removeValue(forKey: wrapper.key)
                } else {
                    try store.setValue(newValue, forKey: wrapper.key)
                }
            } catch {
                preconditionFailure("Failed to set '\(wrapper.key)': \(error)")
            }
        }
    }
    
    private static func cache<EnclosingType: KeyValueStoreCoordinator>(
        at storageKeyPath: ReferenceWritableKeyPath<EnclosingType, Self>,
        in instance: EnclosingType
    ) -> Stored.Cache {
        let wrapper = instance[keyPath: storageKeyPath]
        
        if let cache = wrapper.cache {
            return cache
        }
        
        let cache = Cache(store: instance.store,
                          key: wrapper.key,
                          defaultValue: wrapper.defaultValue)
        
        wrapper.cache = cache
        
        return cache
    }
    
    public typealias Publisher = AnyPublisher<Value, Never>
    
    @available(*, unavailable, message: "@Stored can only be applied to KeyValueStoreCoordinator")
    public var projectedValue: Publisher {
        get { preconditionFailure() }
    }
    
    public static subscript<EnclosingType: KeyValueStoreCoordinator>(
        _enclosingInstance instance: EnclosingType,
        projected projectedKeyPath: KeyPath<EnclosingType, Publisher>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingType, Self>
    ) -> Publisher {
        get {
            return cache(at: storageKeyPath, in: instance).$value.eraseToAnyPublisher()
        }
    }
}

private extension Stored {
    @propertyWrapper
    class Box {
        var wrappedValue: Cache?
    }
    
    class Cache {
        @Published
        private(set) var value: Value
        
        private var subscriptions: Set<AnyCancellable> = []
        
        init(store: KeyValueStore, key: String, defaultValue: Value) {
            value = Cache.value(forKey: key, in: store) ?? defaultValue
            
            store.objectDidChange.filter({ $0 == key }).sink { [unowned self, unowned store] _ in
                value = Cache.value(forKey: key, in: store) ?? defaultValue
            }
            .store(in: &subscriptions)
        }
        
        private static func value(forKey key: String, in store: KeyValueStore) -> Value? {
            do {
                return try store.value(forKey: key, ofType: Value.self)
            } catch {
                assertionFailure("Failed to get '\(key)': \(error)")
                store.removeValue(forKey: key)
                return nil
            }
        }
    }
}
