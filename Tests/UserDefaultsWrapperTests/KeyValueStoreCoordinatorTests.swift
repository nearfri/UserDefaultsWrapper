import XCTest
import Combine
import UserDefaultsWrapper

private typealias Default = FakeCoordinator.Default

final class KeyValueStoreCoordinatorTests: XCTestCase {
    private var sut: FakeCoordinator!
    private var keyValueStore: KeyValueStore!
    private var subscriptions: Set<AnyCancellable> = []
    
    override func setUpWithError() throws {
        keyValueStore = InMemoryStore()
        sut = FakeCoordinator(store: keyValueStore)
    }
    
    override func tearDownWithError() throws {
        subscriptions = []
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
    
    func test_roundTrip() throws {
        sut.intNum = 7
        XCTAssertEqual(sut.intNum, 7)
        
        sut.optIntNum = 5
        XCTAssertEqual(sut.optIntNum, 5)
        
        sut.oddOptIntNum = nil
        XCTAssertEqual(sut.oddOptIntNum, nil)
        
        sut.str = "hi"
        XCTAssertEqual(sut.str, "hi")
        
        sut.oddOptStr = nil
        XCTAssertEqual(sut.oddOptStr, nil)
        
        sut.rect = CGRect(x: 5, y: 6, width: 7, height: 8)
        XCTAssertEqual(sut.rect, CGRect(x: 5, y: 6, width: 7, height: 8))
        
        sut.colors = [.yellow, .white]
        XCTAssertEqual(sut.colors, [.yellow, .white])
    }
    
    func test_projectedValue() throws {
        var newStr: String?
        var sutStr: String?
        
        sut.$str.sink { [sut] str in
            newStr = str
            sutStr = sut?.str
        }
        .store(in: &subscriptions)
        
        XCTAssertEqual(newStr, FakeCoordinator.Default.str)
        XCTAssertEqual(sutStr, FakeCoordinator.Default.str)
        
        sut.str = "New Value1"
        
        XCTAssertEqual(newStr, "New Value1")
        XCTAssertEqual(sutStr, FakeCoordinator.Default.str)
        
        sut.str = "New Value2"
        
        XCTAssertEqual(newStr, "New Value2")
        XCTAssertEqual(sutStr, "New Value1")
    }
    
    func test_projectedValue_optional() throws {
        var newNum: Int? = -1
        var sutNum: Int? = -1
        
        sut.$optIntNum.sink { [sut] num in
            newNum = num
            sutNum = sut?.optIntNum
        }
        .store(in: &subscriptions)
        
        XCTAssertEqual(newNum, nil)
        XCTAssertEqual(sutNum, nil)
        
        sut.optIntNum = 3
        
        XCTAssertEqual(newNum, 3)
        XCTAssertEqual(sutNum, nil)
        
        sut.optIntNum = nil
        
        XCTAssertEqual(newNum, nil)
        XCTAssertEqual(sutNum, 3)
    }
    
    func test_objectWillChange() throws {
        // Given
        var oldValue: Int?
        
        XCTAssertEqual(sut.intNum, Default.intNum)
        
        // When
        sut.objectWillChange.sink { [sut] _ in
            oldValue = sut?.intNum
        }
        .store(in: &subscriptions)
        
        sut.intNum = 7
        
        // Then
        XCTAssertNotEqual(oldValue, sut.intNum)
        XCTAssertEqual(oldValue, Default.intNum)
    }
}
