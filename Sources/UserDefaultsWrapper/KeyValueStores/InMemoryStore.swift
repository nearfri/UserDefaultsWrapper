import Foundation
import Combine

extension InMemoryStore {
    public enum Error: Swift.Error {
        case typeMismatch
    }
}

public class InMemoryStore: KeyValueStore {
    private var valuesByKey: [String: Any] = [:]
    
    private let didChange: PassthroughSubject<String, Never> = .init()
    
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
        didChange.send(key)
    }
    
    public func hasValue(forKey key: String) -> Bool {
        return valuesByKey[key] != nil
    }
    
    public func removeValue(forKey key: String) {
        valuesByKey[key] = nil
        didChange.send(key)
    }
    
    @discardableResult
    public func synchronize() -> Bool {
        return true
    }
    
    public var objectDidChange: AnyPublisher<String, Never> {
        return didChange.eraseToAnyPublisher()
    }
}
