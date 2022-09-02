import Foundation
import Combine

class InMemorySettings: ObservableObject {
    @Published var isBold: Bool = false
    @Published var isItalic: Bool = false
    @Published var isUnderline: Bool = false
    @Published var isStrikethrough: Bool = false
    
    @Published var greeting: String = "Hello"
    @Published var updatedDate: Date?
    
    private typealias PublisherKeyPath<T> = KeyPath<InMemorySettings, Published<T>.Publisher>
    
    private static let publisherKeyPaths: [AnyKeyPath: PartialKeyPath<InMemorySettings>] = [
        \FontSettings.isBold: \.$isBold,
        \FontSettings.isItalic: \.$isItalic,
        \FontSettings.isUnderline: \.$isUnderline,
        \FontSettings.isStrikethrough: \.$isStrikethrough,
        \GreetingStore.greeting: \.$greeting,
        \GreetingStore.updatedDate: \.$updatedDate,
    ]
    
    private func publisher<P, T: Codable>(
        forProtocolKeyPath keyPath: KeyPath<P, T>
    ) -> AnyPublisher<T, Never> {
        guard let publisherKeyPath = Self.publisherKeyPaths[keyPath] as? PublisherKeyPath<T>
        else { preconditionFailure("publisherKeyPath not found. \(keyPath)") }
        
        return self[keyPath: publisherKeyPath].eraseToAnyPublisher()
    }
}

extension InMemorySettings: FontSettings {
    func publisher<T: Codable>(for keyPath: KeyPath<FontSettings, T>) -> AnyPublisher<T, Never> {
        return publisher(forProtocolKeyPath: keyPath)
    }
}

extension InMemorySettings: GreetingStore {
    func publisher<T: Codable>(for keyPath: KeyPath<GreetingStore, T>) -> AnyPublisher<T, Never> {
        return publisher(forProtocolKeyPath: keyPath)
    }
}
