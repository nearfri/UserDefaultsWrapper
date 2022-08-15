import Foundation
import Combine
import UserDefaultsWrapperUtil

@propertyWrapper
public struct Stored<Value: Codable> {
    public typealias Publisher = AnyPublisher<Value, Never>
    
    let key: String
    private let defaultValue: Value
    
    @Box
    private var cache: Cache!
    
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
            instance.lastAccessedWrappedKeyPath = wrappedKeyPath
            
            return instance[keyPath: storageKeyPath].cache.value
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
    
    func setup(with storeCoordinator: KeyValueStoreCoordinator) {
        let cache = Cache(store: storeCoordinator.store,
                          key: key,
                          defaultValue: defaultValue)
        
        self.cache = cache
        
        storeCoordinator.registerStoragePublisher(cache.$value)
    }
    
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
            return publisher(instance: instance, storageKeyPath: storageKeyPath)
        }
    }
    
    static func publisher<EnclosingType: KeyValueStoreCoordinator>(
        instance: EnclosingType,
        storageKeyPath: KeyPath<EnclosingType, Self>
    ) -> Publisher {
        return instance[keyPath: storageKeyPath].cache.$value.eraseToAnyPublisher()
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
        
        private var subscription: AnyCancellable?
        
        init(store: KeyValueStore, key: String, defaultValue: Value) {
            value = Cache.value(forKey: key, in: store) ?? defaultValue
            
            subscription = store.objectDidChange
                .filter({ $0 == key })
                .sink { [unowned self, unowned store] _ in
                    value = Cache.value(forKey: key, in: store) ?? defaultValue
                }
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
