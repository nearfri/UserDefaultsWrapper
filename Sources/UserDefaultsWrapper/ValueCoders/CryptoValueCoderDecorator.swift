import Foundation
import CryptoKit

public class CryptoValueCoderDecorator: ValueCoder {
    public typealias Key = String
    
    private let valueCoder: ValueCoder
    private let cryptor: Cryptor
    private let dataTransformer: DataTransformer
    private let encryptionPredicate: (Key) -> Bool
    
    public init(
        valueCoder: ValueCoder,
        symmetricKey: String, // SymmetricKeySize.bits256
        encryptWhere predicate: @escaping (Key) -> Bool
    ) {
        self.valueCoder = valueCoder
        self.cryptor = Cryptor(symmetricKey: symmetricKey)
        self.dataTransformer = DataTransformer()
        self.encryptionPredicate = predicate
    }
    
    public func encode<T: Encodable>(_ value: T, forKey key: String) throws -> Any {
        if shouldEncryptValue(forKey: key) {
            let encryptedData = try encrypt(value)
            return try valueCoder.encode(encryptedData, forKey: key)
        } else {
            return try valueCoder.encode(value, forKey: key)
        }
    }
    
    public func decode<T: Decodable>(
        _ type: T.Type,
        from value: Any,
        forKey key: String
    ) throws -> T {
        if shouldEncryptValue(forKey: key) {
            let encryptedData = try valueCoder.decode(Data.self, from: value, forKey: key)
            return try decrypt(type, from: encryptedData)
        } else {
            return try valueCoder.decode(type, from: value, forKey: key)
        }
    }
    
    private func shouldEncryptValue(forKey key: String) -> Bool {
        return encryptionPredicate(key)
    }
    
    private func encrypt<T: Encodable>(_ value: T) throws -> Data {
        let data = try dataTransformer.data(from: value)
        let encryptedData = try cryptor.encrypt(data)
        return encryptedData
    }
    
    private func decrypt<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decryptedData = try cryptor.decrypt(data)
        let value = try dataTransformer.value(type, from: decryptedData)
        return value
    }
}

private struct DataTransformer {
    func data<T: Encodable>(from value: T) throws -> Data {
        switch value {
        case let data as Data:
            return data
        case let string as String:
            return Data(string.utf8)
        default:
            return try JSONEncoder().encode(value)
        }
    }
    
    func value<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        switch type {
        case is Data.Type:
            return data as! T
        case is String.Type:
            return String(decoding: data, as: UTF8.self) as! T
        default:
            return try JSONDecoder().decode(type, from: data)
        }
    }
}

private struct Cryptor {
    private let key: SymmetricKey
    
    init(symmetricKey: String) {
        self.key = SymmetricKey(data: Data(symmetricKey.utf8))
        
        precondition(key.bitCount == SymmetricKeySize.bits256.bitCount, "incorrectKeySize")
    }
    
    func encrypt(_ data: Data) throws -> Data {
        let sealedBox = try ChaChaPoly.seal(data, using: key)
        return sealedBox.combined
    }
    
    func decrypt(_ data: Data) throws -> Data {
        let sealedBox = try ChaChaPoly.SealedBox(combined: data)
        return try ChaChaPoly.open(sealedBox, using: key)
    }
}
