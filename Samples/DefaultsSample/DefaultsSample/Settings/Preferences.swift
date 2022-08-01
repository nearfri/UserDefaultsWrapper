import Foundation
import Combine
import UserDefaultsWrapper
import UserDefaultsWrapperPlus

final class Preferences: KeyValueStoreCoordinator, KeyValueLookup, Settings {
    @Stored("isBold")
    var isBold: Bool = false
    
    @Stored("isItalic")
    var isItalic: Bool = false
    
    @Stored("isUnderline")
    var isUnderline: Bool = false
    
    @Stored("isStrikethrough")
    var isStrikethrough: Bool = false
    
    @Stored("age")
    var age: Int = 30
    
    @Stored("greeting")
    var greeting: String = "hello"
    
    @Stored("updatedDate")
    var updatedDate: Date?
    
    static let standard: Preferences = .init(
        store: UserDefaultsStore(
            defaults: .standard,
            valueCoder: ObjectValueCoder()))
    
    #if DEBUG
    static let inMemory: Preferences = .init(store: InMemoryStore())
    #endif
}
