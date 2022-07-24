import XCTest
import Combine
import UserDefaultsWrapper

final class KeyValueStoreTests: XCTestCase {
    private var sut: KeyValueStore!
    
    private var subscriptions: Set<AnyCancellable> = []
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        subscriptions = []
        sut = nil
    }
    
    func testInMemoryStoreRountTrip() throws {
        sut = InMemoryStore()
        try runTestRoundTrip()
    }
    
    func testUserDefaultsStoreRoundTrip() throws {
        sut = UserDefaultsStore(defaults: .standard, valueCoder: JSONValueCoder())
        try runTestRoundTrip()
    }
    
    func runTestRoundTrip() throws {
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
        let key = "anonymousKey"
        defer { sut.removeValue(forKey: key) }
        
        do {
            try sut.setValue(value, forKey: key)
            let loadedValue = try sut.value(forKey: key, ofType: T.self)
            
            XCTAssertEqual(loadedValue, value, "\(type(of: sut!)), value type: \(T.self)",
                           file: file, line: line)
        } catch {
            XCTFail("\(error) - \(type(of: sut!)), value type: \(T.self)",
                    file: file, line: line)
        }
    }
    
    func testInMemoryStoreChangePublisher() throws {
        sut = InMemoryStore()
        runTestChangePublisher()
    }
    
    func testUserDefaultsStoreChangePublisher() throws {
        sut = UserDefaultsStore(defaults: .standard, valueCoder: JSONValueCoder())
        runTestChangePublisher()
    }
    
    func runTestChangePublisher() {
        let storeType = type(of: sut!)
        
        do {
            let key = "anonymousKey"
            
            defer { sut.removeValue(forKey: key) }
            
            var valueBefore: String?
            var valueAfter: String?
            var currentValue: String?
            
            sut.objectWillChange.sink { [sut] k in
                XCTAssertEqual(k, key, "\(storeType)")
                valueBefore = try? sut!.value(forKey: key, ofType: String.self)
            }
            .store(in: &subscriptions)
            
            sut.objectDidChange.sink { [sut] k in
                XCTAssertEqual(k, key, "\(storeType)")
                valueAfter = try? sut!.value(forKey: key, ofType: String.self)
            }
            .store(in: &subscriptions)
            
            try sut.setValue("Step 1", forKey: key)
            currentValue = try sut.value(forKey: key, ofType: String.self)
            
            XCTAssertEqual(currentValue, "Step 1", "\(storeType)")
            XCTAssertEqual(valueBefore, nil, "\(storeType)")
            XCTAssertEqual(valueAfter, "Step 1", "\(storeType)")
            
            (valueBefore, valueAfter, currentValue) = (nil, nil, nil)
            
            try sut.setValue("Step 2", forKey: key)
            currentValue = try sut.value(forKey: key, ofType: String.self)
            
            XCTAssertEqual(currentValue, "Step 2", "\(storeType)")
            XCTAssertEqual(valueBefore, "Step 1", "\(storeType)")
            XCTAssertEqual(valueAfter, "Step 2", "\(storeType)")
        } catch {
            XCTFail("\(error) - \(storeType)")
        }
    }
}
