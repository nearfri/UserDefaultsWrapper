import Foundation
import CoreGraphics
import Combine
import UserDefaultsWrapper

// MARK: - ColorType

enum ColorType: String, Codable {
    case red
    case blue
    case green
    case black
    case white
    case yellow
}

// MARK: - Product

struct Product: Codable, Equatable {
    var name: String
}

extension Product {
    static let banana: Product = .init(name: "Banana")
}

// MARK: - FakeCoordinator

extension FakeCoordinator {
    enum Default {
        static let intNum: Int = 3
        static let optIntNum: Int? = nil
        static let oddOptIntNum: Int? = 4
        static let str: String = "Hello"
        static let oddOptStr: String? = "World"
        static let rect: CGRect = CGRect(x: 1, y: 2, width: 3, height: 4)
        static let colors: [ColorType] = [.blue, .black, .green]
    }
}

final class FakeCoordinator: KeyValueStoreCoordinator {
    @Stored("intNum")
    var intNum: Int = Default.intNum
    
    @Stored("optIntNum")
    var optIntNum: Int? = Default.optIntNum
    
    @Stored("oddOptIntNum")
    var oddOptIntNum: Int? = Default.oddOptIntNum
    
    @Stored("str")
    var str: String = Default.str
    
    @Stored("oddOptStr")
    var oddOptStr: String? = Default.oddOptStr
    
    @Stored("rect")
    var rect: CGRect = Default.rect
    
    @Stored("colors")
    var colors: [ColorType] = Default.colors
}

extension FakeCoordinator: KeyValueLookup {}

// MARK: - FakeSettings

protocol FakeSettings: AnyObject {
    var intNum: Int { get set }
    
    func publisher<T: Codable>(for keyPath: KeyPath<FakeSettings, T>) -> AnyPublisher<T, Never>
}

extension FakeCoordinator: FakeSettings {
    func publisher<T: Codable>(for keyPath: KeyPath<FakeSettings, T>) -> AnyPublisher<T, Never> {
        do {
            let concreteKeyPath = try keyPathConverted(fromProtocolKeyPath: keyPath)
            
            return try publisher(for: concreteKeyPath).eraseToAnyPublisher()
        } catch {
            preconditionFailure("\(error)")
        }
    }
}
