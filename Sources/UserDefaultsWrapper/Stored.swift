import Foundation
import UserDefaultsWrapperUtil

@propertyWrapper
public struct Stored<Value: Codable> {
    let key: String
    private let defaultValue: Value
    
    public init(wrappedValue: Value, _ key: String) {
        self.defaultValue = wrappedValue
        self.key = key
    }
    
    public init<OptionalWrapped>(_ key: String) where Value == OptionalWrapped? {
        self.init(wrappedValue: nil, key)
    }
    
    // https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-wrappers.md#referencing-the-enclosing-self-in-a-wrapper-type
    public static subscript<EnclosingType: KeyValueStoreCoordinator>(
        _enclosingInstance instance: EnclosingType,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingType, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingType, Self>
    ) -> Value {
        get {
            instance.register(storageKeyPath: storageKeyPath, forWrappedKeyPath: wrappedKeyPath)
            
            let wrapper = instance[keyPath: storageKeyPath]
            let store = instance.store
            
            do {
                let storedValue = try store.value(forKey: wrapper.key, ofType: Value.self)
                return storedValue ?? wrapper.defaultValue
            } catch {
                assertionFailure("Failed to get '\(wrapper.key)': \(error)")
                store.removeValue(forKey: wrapper.key)
                return wrapper.defaultValue
            }
        }
        set {
            let wrapper = instance[keyPath: storageKeyPath]
            let store = instance.store
            
            do {
                if isNilValue(newValue) && isNilValue(wrapper.defaultValue) {
                    store.removeValue(forKey: wrapper.key)
                } else {
                    try store.setValue(newValue, forKey: wrapper.key)
                }
            } catch {
                preconditionFailure("Failed to set '\(wrapper.key)': \(error)")
            }
        }
    }
    
    @available(*, unavailable, message: "@Stored can only be applied to KeyValueStoreCoordinator")
    public var wrappedValue: Value {
        get { preconditionFailure() }
        set { preconditionFailure() }
    }
}
