import Foundation
import UserDefaultsWrapper

final class FooCoordinator: KeyValueStoreCoordinator, KeyValueLookup {
    @Stored("greeting")
    var greeting: String = "hello"
    
    func foo() {
        
    }
}
