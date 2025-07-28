import Foundation

extension TrieDictionary: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Value)...) {
        self.init()
        for (key, value) in elements {
            self[key] = value
        }
    }
}

extension TrieDictionary: CustomStringConvertible {
    public var description: String {
        let keyValuePairs = self.map { "\"\($0.key)\": \($0.value)" }
        return "[\(keyValuePairs.joined(separator: ", "))]"
    }
}

extension TrieDictionary: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "TrieDictionary(\(description))"
    }
}

extension TrieDictionary where Value: Equatable {
    public static func == (lhs: TrieDictionary<Value>, rhs: TrieDictionary<Value>) -> Bool {
        guard lhs.count == rhs.count else { return false }
        
        for (key, value) in lhs {
            guard let rhsValue = rhs[key], rhsValue == value else {
                return false
            }
        }
        return true
    }
}

extension TrieDictionary {
    public func mapValues<T>(_ transform: (Value) throws -> T) rethrows -> TrieDictionary<T> {
        var result = TrieDictionary<T>()
        for (key, value) in self {
            result[key] = try transform(value)
        }
        return result
    }
    
    public func compactMapValues<T>(_ transform: (Value) throws -> T?) rethrows -> TrieDictionary<T> {
        var result = TrieDictionary<T>()
        for (key, value) in self {
            if let transformedValue = try transform(value) {
                result[key] = transformedValue
            }
        }
        return result
    }
    
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> TrieDictionary<Value> {
        var result = TrieDictionary<Value>()
        for element in self {
            if try isIncluded(element) {
                result[element.key] = element.value
            }
        }
        return result
    }
    
    public mutating func merge(_ other: TrieDictionary<Value>, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows {
        for (key, value) in other {
            if let existingValue = self[key] {
                self[key] = try combine(existingValue, value)
            } else {
                self[key] = value
            }
        }
    }
    
    public func merging(_ other: TrieDictionary<Value>, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> TrieDictionary<Value> {
        var result = self
        try result.merge(other, uniquingKeysWith: combine)
        return result
    }
}