import Foundation

public class UserDefaultsStore: KeyValueStore {
    public let defaults: UserDefaults
    public let valueCoder: ValueCoder
    
    public init(defaults: UserDefaults = .standard, valueCoder: ValueCoder) {
        self.defaults = defaults
        self.valueCoder = valueCoder
    }
    
    public func value<T: Codable>(forKey key: String, ofType type: T.Type) throws -> T? {
        guard let encodedValue = defaults.object(forKey: key) else { return nil }
        return try valueCoder.decode(type, from: encodedValue)
    }
    
    public func setValue<T: Codable>(_ value: T, forKey key: String) throws {
        let encodedValue = try valueCoder.encode(value)
        defaults.set(encodedValue, forKey: key)
    }
    
    public func removeValue(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
    
    @discardableResult
    public func synchronize() -> Bool {
        return defaults.synchronize()
    }
}
