import Foundation
import Combine

protocol GreetingStore: AnyObject {
    var greeting: String { get set }
    var updatedDate: Date? { get set }
    
    var objectWillChange: ObservableObjectPublisher { get }
    
    func publisher<T: Codable>(for keyPath: KeyPath<GreetingStore, T>) -> AnyPublisher<T, Never>
}
