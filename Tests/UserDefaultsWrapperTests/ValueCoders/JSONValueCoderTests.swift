import XCTest
import UserDefaultsWrapper

final class JSONValueCoderTests: XCTestCase {
    private let sut: JSONValueCoder = .init()
    
    func test_encode_decode() throws {
        testRoundTrip(of: true)
        testRoundTrip(of: false)
        testRoundTrip(of: true as Bool?)
        testRoundTrip(of: nil as Bool?)
        
        testRoundTrip(of: 3)
        testRoundTrip(of: 3 as Int?)
        testRoundTrip(of: nil as Int?)
        
        testRoundTrip(of: 3.2)
        testRoundTrip(of: 3.2 as Double?)
        testRoundTrip(of: nil as Double?)
        
        testRoundTrip(of: "hello")
        testRoundTrip(of: "hello" as String?)
        testRoundTrip(of: nil as String?)
        
        testRoundTrip(of: Data([1, 2, 3]))
        testRoundTrip(of: Data([1, 2, 3]) as Data?)
        testRoundTrip(of: nil as Data?)
        
        testRoundTrip(of: Date())
        testRoundTrip(of: Date() as Date?)
        testRoundTrip(of: nil as Date?)
        
        testRoundTrip(of: ColorType.blue)
        testRoundTrip(of: ColorType.blue as ColorType?)
        testRoundTrip(of: nil as ColorType?)
        
        testRoundTrip(of: Product.banana)
        testRoundTrip(of: Product.banana as Product?)
        testRoundTrip(of: nil as Product?)
    }
    
    private func testRoundTrip<T>(
        of value: T,
        file: StaticString = #file,
        line: UInt = #line
    ) where T: Codable, T: Equatable {
        let defaults = UserDefaults.standard
        let key = "anonymousKey-\(type(of: self))"
        defer { defaults.removeObject(forKey: key) }
        
        let encodedValue: Any
        do {
            encodedValue = try sut.encode(value, forKey: key)
        } catch {
            XCTFail("\(error) - while encoding \(T.self)", file: file, line: line)
            return
        }
        
        defaults.set(encodedValue, forKey: key)
        let loadedObject = defaults.object(forKey: key)!
        
        do {
            let decodedValue = try sut.decode(T.self, from: loadedObject, forKey: key)
            XCTAssertEqual(decodedValue, value, "value type: \(T.self)",
                           file: file, line: line)
        } catch {
            XCTFail("\(error) - while decoding \(T.self)", file: file, line: line)
        }
    }
}
