import XCTest
import UserDefaultsWrapper

func testRoundTrip<T>(
    of value: T,
    using coder: ObjectValueCoder,
    file: StaticString = #file,
    line: UInt = #line
) where T: Codable, T: Equatable {
    let defaults = UserDefaults.standard
    let key = "anonymousKey"
    defer { defaults.removeObject(forKey: key) }
    
    let encodedValue: Any
    do {
        encodedValue = try coder.encode(value)
    } catch {
        XCTFail("Failed to encode \(T.self): \(error)", file: file, line: line)
        return
    }
    
    defaults.set(encodedValue, forKey: key)
    let loadedObject = defaults.object(forKey: key)!
    
    do {
        let decodedValue = try coder.decode(T.self, from: loadedObject)
        XCTAssertEqual(decodedValue, value, "\(T.self) did not round-trip to an equal value.",
                       file: file, line: line)
    } catch {
        XCTFail("Failed to decode \(T.self): \(error)", file: file, line: line)
    }
}

func testRoundTrip<T>(
    of value: T,
    using store: KeyValueStore,
    file: StaticString = #file,
    line: UInt = #line
) where T: Codable, T: Equatable {
    let key = "anonymousKey"
    defer { store.removeValue(forKey: key) }
    
    do {
        try store.setValue(value, forKey: key)
        let loadedValue = try store.value(forKey: key, ofType: T.self)
        
        XCTAssertEqual(loadedValue, value, "\(T.self) did not round-trip to an equal value.",
                       file: file, line: line)
    } catch {
        XCTFail("Failed to round-trip \(T.self): \(error)", file: file, line: line)
    }
}
