import Foundation
import Combine

class InMemorySettings: Settings, ObservableObject {
    @Published var isBold: Bool = false
    @Published var isItalic: Bool = false
    @Published var isUnderline: Bool = false
    @Published var isStrikethrough: Bool = false
    
    @Published var greeting: String = "Hello"
    
    @Published var updatedDate: Date?
    
    private typealias PublisherKeyPath<T> = KeyPath<InMemorySettings, Published<T>.Publisher>
    
    private static let publisherKeyPaths: [AnyKeyPath: PartialKeyPath<InMemorySettings>] = [
        \Settings.isBold: \.$isBold,
        \Settings.isItalic: \.$isItalic,
        \Settings.isUnderline: \.$isUnderline,
        \Settings.isStrikethrough: \.$isStrikethrough,
        \Settings.greeting: \.$greeting,
        \Settings.updatedDate: \.$updatedDate,
    ]
    
    func publisher<T: Codable>(for keyPath: KeyPath<Settings, T>) -> AnyPublisher<T, Never> {
        guard let publisherKeyPath = Self.publisherKeyPaths[keyPath] as? PublisherKeyPath<T>
        else { preconditionFailure("publisherKeyPath not found. \(keyPath)") }
        
        return self[keyPath: publisherKeyPath].eraseToAnyPublisher()
    }
}
