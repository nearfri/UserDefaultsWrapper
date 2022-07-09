import XCTest
import UserDefaultsWrapper

private typealias Default = FakeCoordinator.Default

final class KeyValueLookupTests: XCTestCase {
    private var sut: FakeCoordinator!
    private var keyValueStore: KeyValueStore!
    
    override func setUpWithError() throws {
        keyValueStore = InMemoryStore()
        sut = FakeCoordinator(store: keyValueStore)
    }
    
    func test_keyForKeyPath() throws {
        XCTAssertEqual(try sut.key(for: \.intNum), "intNum")
    }
    
    func test_storedValue_ofFirstLaunch_returnNil() throws {
        XCTAssertNil(try sut.storedValue(for: \.intNum))
        XCTAssertFalse(sut.hasStoredValue(for: \.intNum))
    }
    
    func test_storedValue_ofNextLaunch_returnValue() throws {
        // Given
        sut.intNum = 7
        sut = nil
        
        // When
        sut = FakeCoordinator(store: keyValueStore)
        
        // Then
        XCTAssertEqual(try sut.storedValue(for: \.intNum), 7)
        XCTAssertTrue(sut.hasStoredValue(for: \.intNum))
    }
    
    func test_removeStoredValue() throws {
        // Given
        sut.intNum = 7
        
        // When
        sut.removeStoredValue(for: \.intNum)
        
        // Then
        XCTAssertFalse(sut.hasStoredValue(for: \.intNum))
        XCTAssertEqual(sut.intNum, Default.intNum)
    }
    
    func test_removeAllStoredValues() throws {
        // Given
        sut.intNum = 7
        sut.str = "Welcome"
        sut.rect = CGRect(x: 5, y: 6, width: 7, height: 8)
        
        // when
        sut.removeAllStoredValues()
        
        // Then
        XCTAssertFalse(sut.hasStoredValue(for: \.intNum))
        XCTAssertFalse(sut.hasStoredValue(for: \.str))
        XCTAssertFalse(sut.hasStoredValue(for: \.rect))
        XCTAssertEqual(sut.intNum, Default.intNum)
        XCTAssertEqual(sut.str, Default.str)
        XCTAssertEqual(sut.rect, Default.rect)
    }
    
    func test_setter_optional() throws {
        // Given
        sut.optIntNum = 7
        
        // When
        sut.optIntNum = nil
        
        // Then
        XCTAssertNil(sut.optIntNum)
        XCTAssertFalse(sut.hasStoredValue(for: \.optIntNum))
    }
    
    func test_setter_oddOptional() throws {
        // Given
        sut.oddOptIntNum = 7
        
        // When
        sut.oddOptIntNum = nil
        
        // Then
        XCTAssertNil(sut.oddOptIntNum)
        XCTAssertTrue(sut.hasStoredValue(for: \.oddOptIntNum))
    }
}
