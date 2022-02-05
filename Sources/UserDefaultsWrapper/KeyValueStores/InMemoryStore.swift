import Foundation

extension InMemoryStore {
    public enum Error: Swift.Error {
        case typeMismatch
    }
}

public class InMemoryStore: KeyValueStore {
    private var valuesByKey: [String: Any] = [:]
    
    public init() {}
    
    public func value<T: Codable>(forKey key: String, ofType type: T.Type) throws -> T? {
        guard let value = valuesByKey[key] else { return nil }
        
        if let value = value as? T {
            return value
        } else {
            throw Error.typeMismatch
        }
    }
    
    public func setValue<T: Codable>(_ value: T, forKey key: String) throws {
        valuesByKey[key] = value
    }
    
    public func removeValue(forKey key: String) {
        valuesByKey[key] = nil
    }
    
    @discardableResult
    public func synchronize() -> Bool {
        return true
    }
}
