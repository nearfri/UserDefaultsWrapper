import Foundation
import SwiftUI

@propertyWrapper
struct AppSetting<T> {
    private let keyPath: ReferenceWritableKeyPath<Settings, T>
    
    init(_ keyPath: ReferenceWritableKeyPath<Settings, T>) {
        self.keyPath = keyPath
    }
    
    // TODO: standard에 직접 접근 안하고 Environment 쓰도록 변경. preview에서 UserDefaults 쓰면 어떻게 되는지 확인 필요
    // Environment 등록 시 기본은 inMemory로 해서 Preview나 테스트에 영향이 없도록 하고 composition root에서
    // standard로 등록하는게 좋겠다.
    var wrappedValue: T {
        get { Preferences.standard[keyPath: keyPath] }
        nonmutating set { Preferences.standard[keyPath: keyPath] = newValue }
    }
}
