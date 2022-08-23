import XCTest
import UserDefaultsWrapper

private class PassthroughValueCoder: ValueCoder {
    func encode<T: Encodable>(_ value: T, forKey key: String) throws -> Any {
        return value
    }
    
    func decode<T: Decodable>(_ type: T.Type, from value: Any, forKey key: String) throws -> T {
        return value as! T
    }
}

final class CryptoValueCoderDecoratorTests: XCTestCase {
    private var sut: CryptoValueCoderDecorator!
    
    override func setUpWithError() throws {
        sut = CryptoValueCoderDecorator(
            valueCoder: PassthroughValueCoder(),
            symmetricKey: String(repeating: "A", count: 32),
            shouldEncrypt: { $0.hasPrefix("enc_") })
    }
    
    func test_roundTrip_whenEncrypt() throws {
        // When
        let encoded = try sut.encode("hello", forKey: "enc_greeting")
        let decoded = try sut.decode(String.self, from: encoded, forKey: "enc_greeting")
        
        // Then
        XCTAssertFalse(encoded is String)
        XCTAssertEqual(decoded, "hello")
    }
    
    func test_roundTrip_whenNotEncrypt() throws {
        // When
        let encoded = try sut.encode("hello", forKey: "greeting")
        let decoded = try sut.decode(String.self, from: encoded, forKey: "greeting")
        
        // Then
        XCTAssertEqual(encoded as? String, "hello")
        XCTAssertEqual(decoded, "hello")
    }
}
