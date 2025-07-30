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
    
    // MARK: - Functional Operations
    
    public func setting(key: String, value: Value) -> TrieDictionary<Value> {
        var result = self
        result[key] = value
        return result
    }
    
    public func setting(_ pairs: (String, Value)...) -> TrieDictionary<Value> {
        var result = self
        for (key, value) in pairs {
            result[key] = value
        }
        return result
    }
    
    public func setting<S: Sequence>(_ pairs: S) -> TrieDictionary<Value> where S.Element == (String, Value) {
        var result = self
        for (key, value) in pairs {
            result[key] = value
        }
        return result
    }
    
    public func updatingValue(_ value: Value, forKey key: String) -> (TrieDictionary<Value>, Value?) {
        var result = self
        let oldValue = result.updateValue(value, forKey: key)
        return (result, oldValue)
    }
    
    public func removingValue(forKey key: String) -> (TrieDictionary<Value>, Value?) {
        var result = self
        let oldValue = result.removeValue(forKey: key)
        return (result, oldValue)
    }
    
    public func removing(key: String) -> TrieDictionary<Value> {
        var result = self
        result[key] = nil
        return result
    }
    
    public func removing(_ keys: String...) -> TrieDictionary<Value> {
        var result = self
        for key in keys {
            result[key] = nil
        }
        return result
    }
    
    public func removing<S: Sequence>(_ keys: S) -> TrieDictionary<Value> where S.Element == String {
        var result = self
        for key in keys {
            result[key] = nil
        }
        return result
    }
    
    public func removingAll() -> TrieDictionary<Value> {
        return TrieDictionary<Value>()
    }
    
    public func removingAll(where shouldRemove: (Element) throws -> Bool) rethrows -> TrieDictionary<Value> {
        var result = TrieDictionary<Value>()
        for element in self {
            if try !shouldRemove(element) {
                result[element.key] = element.value
            }
        }
        return result
    }
    
    public func keepingOnly(where shouldKeep: (Element) throws -> Bool) rethrows -> TrieDictionary<Value> {
        var result = TrieDictionary<Value>()
        for element in self {
            if try shouldKeep(element) {
                result[element.key] = element.value
            }
        }
        return result
    }
    
    // MARK: - Additional Functional Operations
    
    /// Returns a new TrieDictionary containing only the keys that satisfy the given predicate
    public func filteringKeys(_ isIncluded: (String) throws -> Bool) rethrows -> TrieDictionary<Value> {
        var result = TrieDictionary<Value>()
        for (key, value) in self {
            if try isIncluded(key) {
                result[key] = value
            }
        }
        return result
    }
    
    /// Returns a new TrieDictionary containing only the values that satisfy the given predicate
    public func filteringValues(_ isIncluded: (Value) throws -> Bool) rethrows -> TrieDictionary<Value> {
        var result = TrieDictionary<Value>()
        for (key, value) in self {
            if try isIncluded(value) {
                result[key] = value
            }
        }
        return result
    }
    
    /// Returns a new TrieDictionary with keys transformed by the given closure
    public func mapKeys(_ transform: (String) throws -> String) rethrows -> TrieDictionary<Value> {
        var result = TrieDictionary<Value>()
        for (key, value) in self {
            let newKey = try transform(key)
            result[newKey] = value
        }
        return result
    }
    
    /// Returns a new TrieDictionary containing only keys with the specified prefix
    public func withPrefix(_ prefix: String) -> TrieDictionary<Value> {
        return filteringKeys { $0.hasPrefix(prefix) }
    }
    
    /// Returns a new TrieDictionary containing only keys with the specified suffix
    public func withSuffix(_ suffix: String) -> TrieDictionary<Value> {
        return filteringKeys { $0.hasSuffix(suffix) }
    }
    
    /// Returns a new TrieDictionary containing only keys matching the specified pattern
    public func matching(_ predicate: (String) -> Bool) -> TrieDictionary<Value> {
        return filteringKeys(predicate)
    }
    
    /// Returns a tuple of two TrieDictionaries: (matching, nonMatching) based on the predicate
    public func partitioned(by predicate: (Element) throws -> Bool) rethrows -> (matching: TrieDictionary<Value>, nonMatching: TrieDictionary<Value>) {
        var matching = TrieDictionary<Value>()
        var nonMatching = TrieDictionary<Value>()
        
        for element in self {
            if try predicate(element) {
                matching[element.key] = element.value
            } else {
                nonMatching[element.key] = element.value
            }
        }
        
        return (matching, nonMatching)
    }
    
    /// Returns a new TrieDictionary with all values replaced by the result of the given closure applied to the key-value pair
    public func replacingValues<T>(_ transform: (String, Value) throws -> T) rethrows -> TrieDictionary<T> {
        var result = TrieDictionary<T>()
        for (key, value) in self {
            result[key] = try transform(key, value)
        }
        return result
    }
    
    /// Returns a new TrieDictionary containing only entries where the key length matches the condition
    public func filteringKeyLength(_ condition: (Int) -> Bool) -> TrieDictionary<Value> {
        return filteringKeys { condition($0.count) }
    }
    
    /// Returns a new TrieDictionary with keys having a minimum length
    public func withMinKeyLength(_ minLength: Int) -> TrieDictionary<Value> {
        return filteringKeyLength { $0 >= minLength }
    }
    
    /// Returns a new TrieDictionary with keys having a maximum length
    public func withMaxKeyLength(_ maxLength: Int) -> TrieDictionary<Value> {
        return filteringKeyLength { $0 <= maxLength }
    }
    
    /// Returns a new TrieDictionary with keys having an exact length
    public func withKeyLength(_ exactLength: Int) -> TrieDictionary<Value> {
        return filteringKeyLength { $0 == exactLength }
    }
    
    /// Returns a new TrieDictionary containing entries where values are unique
    public func uniqueValues() -> TrieDictionary<Value> where Value: Hashable {
        var seenValues = Set<Value>()
        var result = TrieDictionary<Value>()
        
        for (key, value) in self {
            if !seenValues.contains(value) {
                seenValues.insert(value)
                result[key] = value
            }
        }
        
        return result
    }
    
    /// Returns a new TrieDictionary by applying a transformation and then filtering out nils
    public func transformAndFilter<T>(_ transform: (Element) throws -> (String, T)?) rethrows -> TrieDictionary<T> {
        var result = TrieDictionary<T>()
        for element in self {
            if let (newKey, newValue) = try transform(element) {
                result[newKey] = newValue
            }
        }
        return result
    }
}