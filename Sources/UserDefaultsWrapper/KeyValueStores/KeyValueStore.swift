import Foundation
import Combine

public protocol KeyValueStore: AnyObject {
    func value<T: Codable>(forKey key: String, ofType type: T.Type) throws -> T?
    func setValue<T: Codable>(_ value: T, forKey key: String) throws
    
    func hasValue(forKey key: String) -> Bool
    func removeValue(forKey key: String)
    
    @discardableResult
    func synchronize() -> Bool
    
    var objectDidChange: AnyPublisher<String, Never> { get }
}
