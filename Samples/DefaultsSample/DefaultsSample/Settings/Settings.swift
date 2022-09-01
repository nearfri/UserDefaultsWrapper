import Foundation
import Combine

protocol Settings: AnyObject {
    var isBold: Bool { get set }
    var isItalic: Bool { get set }
    var isUnderline: Bool { get set }
    var isStrikethrough: Bool { get set }
    
    var greeting: String { get set }
    var updatedDate: Date? { get set }
    
    var objectWillChange: ObservableObjectPublisher { get }
    
    func publisher<T: Codable>(for keyPath: KeyPath<Settings, T>) -> AnyPublisher<T, Never>
}
