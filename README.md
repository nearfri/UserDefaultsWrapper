# UserDefaultsWrapper
[![Swift](https://github.com/nearfri/UserDefaultsWrapper/actions/workflows/swift.yml/badge.svg)](https://github.com/nearfri/UserDefaultsWrapper/actions/workflows/swift.yml)

A Swift library that makes it easy to use UserDefaults.

## Usage
```swift
import UserDefaultsWrapper

enum ColorType: String, Codable {
    case red
    case blue
    case green
    case black
    case white
}

// 1. Define preferences class that inherits `KeyValueStoreCoordinator`.
// 2. Add properties with property wrapper `@Stored`.
final class Preferences: KeyValueStoreCoordinator {
    @Stored("intNum")
    var intNum: Int = 3
    
    @Stored("optIntNum")
    var optIntNum: Int?
    
    @Stored("str")
    var str: String = "hello"
    
    @Stored("rect")
    var rect: CGRect = CGRect(x: 1, y: 2, width: 3, height: 4)
    
    @Stored("colors")
    var colors: [ColorType] = [.blue, .black, .green]
    
    @Stored("dataModificationDate")
    var dataModificationDate: Date?
    
    static let standard: Preferences = {
        return .init(store: UserDefaultsStore(defaults: .standard, valueCoder: JSONValueCoder()))
    }()
}

// 3. Just use it.
let preferences = Preferences.standard

preferences.intNum = 5
assert(preferences.intNum == 5)
assert(UserDefaults.standard.integer(forKey: "intNum") == 5)

preferences.rect.size = CGSize(width: 5, height: 6)
assert(preferences.rect.size == CGSize(width: 5, height: 6))

preferences.$rect.sink { print("\($0)") }

// 4. Add `KeyValueLookup` conformance for more features.
extension Preferences: KeyValueLookup {}

preferences.removeStoredValue(for: \.intNum)
assert(UserDefaults.standard.object(forKey: "intNum") == nil)
assert(preferences.intNum == 3) // Default value
```

For more example usage, see the sample app in `Samples` folder.

## Install

#### Swift Package Manager
```
.package(url: "https://github.com/nearfri/UserDefaultsWrapper", from: "0.9.0")
```

## License
Preferences is released under the MIT license. See [LICENSE](https://github.com/nearfri/UserDefaultsWrapper/blob/master/LICENSE) for more information.



