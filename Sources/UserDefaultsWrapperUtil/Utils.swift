import Foundation

public func isPlistObject(_ value: Any) -> Bool {
    switch value {
    case is NSNumber, is String, is Data, is Date:
        return true
    default:
        return false
    }
}

public func isNilValue(_ value: Any) -> Bool {
    return wrapIfNonOptional(value) == nil
}

public func wrapIfNonOptional(_ value: Any) -> Any? {
    switch value {
    case let optionalValue as Any?:
        return optionalValue
    default:
        return value
    }
}
