import Foundation
import Combine
import UserDefaultsWrapper
import UserDefaultsWrapperPlus

protocol Settings: AnyObject {
    var greeting: String { get set }
    
    func publisher<T: Codable>(for keyPath: KeyPath<Settings, T>) -> AnyPublisher<T, Never>
}

final class Preferences: KeyValueStoreCoordinator, Settings, KeyValueLookup {
    @Stored("age")
    var age: Int = 30
    
    @Stored("greeting")
    var greeting: String = "hello"
    
    static let standard: Preferences = .init(
        store: UserDefaultsStore(
            defaults: .standard,
            valueCoder: ObjectValueCoder()))
    
    static let inMemory: Preferences = .init(store: InMemoryStore())
    
    func publisher<T: Codable>(for keyPath: KeyPath<Settings, T>) -> AnyPublisher<T, Never> {
        let p = unsafePublisher(for: keyPath)
        print(p)
        fatalError()
    }
}
