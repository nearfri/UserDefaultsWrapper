import Foundation
import Combine
import UserDefaultsWrapper
import UserDefaultsWrapperPlus

protocol Settings: AnyObject {
    var greeting: String { get set }
}

final class Preferences: KeyValueStoreCoordinator, KeyValueLookup, Settings {
    @Stored("age")
    var age: Int = 30
    
    @Stored("greeting")
    var greeting: String = "hello"
    
    static let standard: Preferences = .init(
        store: UserDefaultsStore(
            defaults: .standard,
            valueCoder: ObjectValueCoder()))
    
    #if DEBUG
    static let inMemory: Preferences = .init(store: InMemoryStore())
    #endif
}
