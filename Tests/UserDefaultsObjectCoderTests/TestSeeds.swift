import Foundation

enum ColorType: String, Codable {
    case red
    case blue
    case green
}

struct Product: Codable, Equatable {
    var name: String
}

extension Product {
    static let banana: Product = .init(name: "Banana")
}
