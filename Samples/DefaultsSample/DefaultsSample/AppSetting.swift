import Foundation

@propertyWrapper
struct AppSetting<T> {
    private let keyPath: ReferenceWritableKeyPath<Preferences, T>
    
    init(_ keyPath: ReferenceWritableKeyPath<Preferences, T>) {
        self.keyPath = keyPath
    }
    
    // TODO: Environment 쓰도록 변경. preview에서 UserDefaults 쓰면 어떻게 되는지 확인 필요
    var wrappedValue: T {
        get { Preferences.standard[keyPath: keyPath] }
        nonmutating set { Preferences.standard[keyPath: keyPath] = newValue }
    }
}
