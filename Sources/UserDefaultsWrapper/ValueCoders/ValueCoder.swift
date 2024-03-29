import Foundation

public protocol ValueCoder: AnyObject {
    func encode<T: Encodable>(_ value: T, forKey key: String) throws -> Any
    func decode<T: Decodable>(_ type: T.Type, from value: Any, forKey key: String) throws -> T
}
