import XCTest
import UserDefaultsWrapperUtil

enum ColorType: String, Codable {
    case red
    case blue
    case green
}

final class UtilsTests: XCTestCase {
    func test_isPlistObject() throws {
        XCTAssertTrue(isPlistObject(true))
        XCTAssertTrue(isPlistObject(3))
        XCTAssertTrue(isPlistObject(5.3))
        XCTAssertTrue(isPlistObject("hello"))
        XCTAssertTrue(isPlistObject(Data()))
        XCTAssertTrue(isPlistObject(Date()))
        
        XCTAssertTrue(isPlistObject((3 as Int?) as Any))
        XCTAssertFalse(isPlistObject((nil as Int?) as Any))
        
        XCTAssertFalse(isPlistObject(ColorType.blue))
        XCTAssertFalse(isPlistObject(CGRect(x: 1, y: 2, width: 3, height: 4)))
    }
    
    func test_wrapIfNonOptional() throws {
        XCTAssertEqual(wrapIfNonOptional(3) as! Int?, 3)
        
        XCTAssertEqual(wrapIfNonOptional((3 as Int?) as Any) as! Int?, 3)
        
        XCTAssertEqual(wrapIfNonOptional((nil as Int?) as Any) as! Int?, nil)
    }
}
