import Foundation
import UserDefaultsWrapperUtil

extension JSONValueCoder {
    public enum Error: Swift.Error {
        case typeMismatch
    }
}

public class JSONValueCoder: ValueCoder {
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    public init(encoder: JSONEncoder = .init(), decoder: JSONDecoder = .init()) {
        self.encoder = encoder
        self.decoder = decoder
    }
    
    public func encode<T: Encodable>(_ value: T) throws -> Any {
        return isPlistObject(value) ? value : try encoder.encode(value)
    }
    
    public func decode<T: Decodable>(_ type: T.Type, from value: Any) throws -> T {
        var encodedNilData: Data {
            try! self.encoder.encode(nil as Data?)
        }
        
        switch value {
        case let value as T where type != Data?.self:
            return value
        case let data as Data:
            if type == Data?.self && data != encodedNilData {
                return data as! T
            }
            return try decoder.decode(T.self, from: data)
        default:
            throw Error.typeMismatch
        }
    }
}
