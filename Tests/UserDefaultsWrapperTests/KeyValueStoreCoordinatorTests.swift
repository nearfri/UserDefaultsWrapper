import XCTest
import UserDefaultsWrapper

private typealias Default = FakeCoordinator.Default

final class KeyValueStoreCoordinatorTests: XCTestCase {
    private var sut: FakeCoordinator!
    private var keyValueStore: KeyValueStore!
    
    override func setUpWithError() throws {
        keyValueStore = InMemoryStore()
        sut = FakeCoordinator(store: keyValueStore)
    }
    
    func test_init_ofFirstLaunch_hasDefaultValues() throws {
        XCTAssertEqual(sut.intNum, Default.intNum)
        XCTAssertEqual(sut.optIntNum, Default.optIntNum)
        XCTAssertEqual(sut.oddOptIntNum, Default.oddOptIntNum)
        XCTAssertEqual(sut.str, Default.str)
        XCTAssertEqual(sut.oddOptStr, Default.oddOptStr)
        XCTAssertEqual(sut.rect, Default.rect)
        XCTAssertEqual(sut.colors, Default.colors)
    }
    
    func test_init_onNextLaunch_hasChangedValues() throws {
        // Given
        sut.intNum = 7
        sut.optIntNum = 5
        sut.oddOptIntNum = nil
        sut.str = "hi"
        sut.oddOptStr = nil
        sut.rect = CGRect(x: 5, y: 6, width: 7, height: 8)
        sut.colors = [.yellow, .white]
        
        sut = nil
        
        // When
        sut = FakeCoordinator(store: keyValueStore)
        
        // Then
        XCTAssertEqual(sut.intNum, 7)
        XCTAssertEqual(sut.optIntNum, 5)
        XCTAssertEqual(sut.oddOptIntNum, nil)
        XCTAssertEqual(sut.str, "hi")
        XCTAssertEqual(sut.oddOptStr, nil)
        XCTAssertEqual(sut.rect, CGRect(x: 5, y: 6, width: 7, height: 8))
        XCTAssertEqual(sut.colors, [.yellow, .white])
    }
}
