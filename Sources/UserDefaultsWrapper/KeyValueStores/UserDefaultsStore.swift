import Foundation
import Combine

public class UserDefaultsStore: KeyValueStore, ObservableObject {
    public let defaults: UserDefaults
    public let valueCoder: ValueCoder
    
    private let cache: KeyValueStore = InMemoryStore()
    private let defaultsObserver: UserDefaultsObserver
    
    public init(defaults: UserDefaults = .standard, valueCoder: ValueCoder) {
        self.defaults = defaults
        self.valueCoder = valueCoder
        self.defaultsObserver = UserDefaultsObserver(defaults: defaults, cache: cache)
    }
    
    public func value<T: Codable>(forKey key: String, ofType type: T.Type) throws -> T? {
        if let cachedValue = try cache.value(forKey: key, ofType: type) {
            return cachedValue
        }
        
        defaultsObserver.addObservation(forKey: key)
        
        guard let encodedValue = defaults.object(forKey: key) else {
            try? cache.setValue(nil as T?, forKey: key)
            return nil
        }
        
        let result = try valueCoder.decode(type, from: encodedValue)
        
        try? cache.setValue(result, forKey: key)
        
        return result
    }
    
    private func addObservation<T: Codable>(forKey key: String, ofType type: T.Type) {
        if defaultsObserver.hasObservation(forKey: key) { return }
        
        _ = try? value(forKey: key, ofType: type)
    }
    
    public func setValue<T: Codable>(_ value: T, forKey key: String) throws {
        let encodedValue = try valueCoder.encode(value)
        
        addObservation(forKey: key, ofType: T.self)
        
        defaults.set(encodedValue, forKey: key)
    }
    
    public func removeValue(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
    
    @discardableResult
    public func synchronize() -> Bool {
        return defaults.synchronize()
    }
    
    public var objectWillChange: AnyPublisher<String, Never> {
        return defaultsObserver.objectWillChange
    }
    
    public var objectDidChange: AnyPublisher<String, Never> {
        return defaultsObserver.objectDidChange
    }
}

private class UserDefaultsObserver: NSObject {
    private let defaults: UserDefaults
    private let cache: KeyValueStore
    private let willChange: PassthroughSubject<String, Never> = .init()
    private let didChange: PassthroughSubject<String, Never> = .init()
    
    private var keys: Set<String> = []
    
    init(defaults: UserDefaults, cache: KeyValueStore) {
        self.defaults = defaults
        self.cache = cache
        
        super.init()
    }
    
    deinit {
        keys.forEach({ defaults.removeObserver(self, forKeyPath: $0) })
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
        if keys.contains(key) { return }
        
        keys.insert(key)
        defaults.addObserver(self, forKeyPath: key, context: nil)
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard let key = keyPath else { return }
        
        willChange.send(key)
        
        cache.removeValue(forKey: key)
        
        didChange.send(key)
    }
}
