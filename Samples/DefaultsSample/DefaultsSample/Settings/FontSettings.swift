import Foundation
import Combine

protocol FontSettings: AnyObject {
    var isBold: Bool { get set }
    var isItalic: Bool { get set }
    var isUnderline: Bool { get set }
    var isStrikethrough: Bool { get set }
    
    var objectWillChange: ObservableObjectPublisher { get }
    
    func publisher<T: Codable>(for keyPath: KeyPath<FontSettings, T>) -> AnyPublisher<T, Never>
}
