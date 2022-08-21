import Foundation
import Combine

public class UserDefaultsStore: KeyValueStore, ObservableObject {
    public let defaults: UserDefaults
    public let valueCoder: ValueCoder
    
    private let defaultsObserver: UserDefaultsObserver
    
    public init(defaults: UserDefaults = .standard, valueCoder: ValueCoder) {
        self.defaults = defaults
        self.valueCoder = valueCoder
        self.defaultsObserver = UserDefaultsObserver(defaults: defaults)
    }
    
    public func value<T: Codable>(forKey key: String, ofType type: T.Type) throws -> T? {
        defaultsObserver.addObservation(forKey: key)
        
        guard let encodedValue = defaults.object(forKey: key) else { return nil }
        return try valueCoder.decode(type, from: encodedValue)
    }
    
    public func setValue<T: Codable>(_ value: T, forKey key: String) throws {
        defaultsObserver.addObservation(forKey: key)
        
        let encodedValue = try valueCoder.encode(value)
        defaults.set(encodedValue, forKey: key)
    }
    
    public func hasValue(forKey key: String) -> Bool {
        return defaults.object(forKey: key) != nil
    }
    
    public func removeValue(forKey key: String) {
        defaultsObserver.addObservation(forKey: key)
        
        defaults.removeObject(forKey: key)
    }
    
    @discardableResult
    public func synchronize() -> Bool {
        return defaults.synchronize()
    }
    
    public var objectDidChange: AnyPublisher<String, Never> {
        return defaultsObserver.objectDidChange
    }
}

private class UserDefaultsObserver: NSObject {
    private let defaults: UserDefaults
    private let didChange: PassthroughSubject<String, Never> = .init()
    
    private var keys: Set<String> = []
    
    init(defaults: UserDefaults) {
        self.defaults = defaults
        
        super.init()
    }
    
    deinit {
        keys.forEach({ defaults.removeObserver(self, forKeyPath: $0) })
    }
    
    var objectDidChange: AnyPublisher<String, Never> {
        return didChange.eraseToAnyPublisher()
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
        
        didChange.send(key)
    }
}
