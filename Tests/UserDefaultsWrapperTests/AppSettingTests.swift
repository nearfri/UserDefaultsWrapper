import XCTest
import SwiftUI
import Combine
@testable import UserDefaultsWrapper

struct FakeSettingsBridge: SettingsBridge {
    typealias Settings = FakeSettings
    
    static var environmentKeyPath: KeyPath<EnvironmentValues, Settings> {
        return \.fakeSettings
    }
    
    static func publisher<T: Codable>(
        for keyPath: KeyPath<Settings, T>,
        of settings: Settings
    ) -> AnyPublisher<T, Never> {
        return settings.publisher(for: keyPath)
    }
}

private struct FakeSettingsKey: EnvironmentKey {
    static let defaultValue: FakeSettings = FakeCoordinator(store: InMemoryStore())
}

extension EnvironmentValues {
    var fakeSettings: FakeSettings {
        get { self[FakeSettingsKey.self] }
        set { self[FakeSettingsKey.self] = newValue }
    }
}

final class AppSettingObserverTests: XCTestCase {
    private var sut: AppSetting<FakeSettingsBridge, Int>.SettingsObserver!
    private var settings: FakeCoordinator!
    private var subscriptions: Set<AnyCancellable> = []
    
    override func setUpWithError() throws {
        sut = .init()
        settings = FakeCoordinator(store: InMemoryStore())
    }
    
    override func tearDownWithError() throws {
        subscriptions = []
    }
    
    func test_objectWillChange_whenValueChange_notify() throws {
        // Given
        sut.observe(\.intNum, of: settings)
        
        var notified = false
        
        sut.objectWillChange.sink { _ in
            notified = true
        }.store(in: &subscriptions)
        
        // When
        settings.intNum = 7
        
        // Then
        XCTAssert(notified)
    }
    
    func test_objectWillChange_whenStartObservation_notNotify() throws {
        // Given
        var notified = false
        
        sut.objectWillChange.sink { _ in
            notified = true
        }.store(in: &subscriptions)
        
        // When
        sut.observe(\.intNum, of: settings)
        
        // Then
        XCTAssertFalse(notified)
    }
}
