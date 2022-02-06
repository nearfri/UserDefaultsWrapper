import Foundation
import UserDefaultsWrapper
import UserDefaultsWrapperUtil
import ObjectCoder

public class ObjectValueCoder: ValueCoder {
    private let encoder: ObjectEncoder
    private let decoder: ObjectDecoder
    
    public init(encoder: ObjectEncoder = .init(), decoder: ObjectDecoder = .init()) {
        self.encoder = encoder
        self.decoder = decoder
    }
    
    public func encode<T: Encodable>(_ value: T) throws -> Any {
        return isPlistObject(value) ? value : try encoder.encode(value)
    }
    
    public func decode<T: Decodable>(_ type: T.Type, from value: Any) throws -> T {
        switch value {
        case let value as T where type != String?.self:
            // ObjectEncoder가 nil은 String으로 저장하므로 Optional<String>은 제외해야 한다.
            return value
        default:
            return try decoder.decode(T.self, from: value)
        }
    }
}
