import Foundation

public struct TrieDictionary<Value> {
    private var root: TrieNode<Value>
    
    public init() {
        self.root = TrieNode()
    }
    
    public var isEmpty: Bool {
        root.isEmpty
    }
    
    public var count: Int {
        root.count
    }
    
    public var rootValue: Value? {
        return self[""]
    }
    
    public subscript(key: String) -> Value? {
        get {
            root.value(for: key)
        }
        set {
            if let newValue = newValue {
                root = root.setting(key: key, value: newValue)
            } else {
                root = root.removing(key: key)
            }
        }
    }
    
    @discardableResult
    public mutating func updateValue(_ value: Value, forKey key: String) -> Value? {
        let oldValue = root.value(for: key)
        root = root.setting(key: key, value: value)
        return oldValue
    }
    
    @discardableResult
    public mutating func removeValue(forKey key: String) -> Value? {
        let oldValue = root.value(for: key)
        root = root.removing(key: key)
        return oldValue
    }
    
    public mutating func removeAll() {
        root = TrieNode()
    }
    
    public func keys() -> [String] {
        root.allKeys()
    }
    
    public func values() -> [Value] {
        root.allValues()
    }
    
    public func traverse(_ prefix: String) -> TrieDictionary<Value> {
        let traversedNode = root.traverse(prefix: prefix)
        var newDict = TrieDictionary<Value>()
        newDict.root = traversedNode
        return newDict
    }
}

// MARK: - Functional Operations
extension TrieDictionary {
    
    public func setting(key: String, value: Value) -> TrieDictionary<Value> {
        var newDict = TrieDictionary<Value>()
        newDict.root = self.root.setting(key: key, value: value)
        return newDict
    }
    
    public func setting(_ keyValuePairs: (String, Value)...) -> TrieDictionary<Value> {
        return setting(keyValuePairs)
    }
    
    public func setting<S: Sequence>(_ keyValuePairs: S) -> TrieDictionary<Value> where S.Element == (String, Value) {
        var newRoot = self.root
        for (key, value) in keyValuePairs {
            newRoot = newRoot.setting(key: key, value: value)
        }
        var newDict = TrieDictionary<Value>()
        newDict.root = newRoot
        return newDict
    }
    
    public func updatingValue(_ value: Value, forKey key: String) -> (dictionary: TrieDictionary<Value>, oldValue: Value?) {
        let oldValue = root.value(for: key)
        var newDict = TrieDictionary<Value>()
        newDict.root = self.root.setting(key: key, value: value)
        return (dictionary: newDict, oldValue: oldValue)
    }
    
    public func removing(key: String) -> TrieDictionary<Value> {
        var newDict = TrieDictionary<Value>()
        newDict.root = self.root.removing(key: key)
        return newDict
    }
    
    public func removing(_ keys: String...) -> TrieDictionary<Value> {
        return removing(keys)
    }
    
    public func removing<S: Sequence>(_ keys: S) -> TrieDictionary<Value> where S.Element == String {
        var newRoot = self.root
        for key in keys {
            newRoot = newRoot.removing(key: key)
        }
        var newDict = TrieDictionary<Value>()
        newDict.root = newRoot
        return newDict
    }
    
    public func removingValue(forKey key: String) -> (dictionary: TrieDictionary<Value>, oldValue: Value?) {
        let oldValue = root.value(for: key)
        var newDict = TrieDictionary<Value>()
        newDict.root = self.root.removing(key: key)
        return (dictionary: newDict, oldValue: oldValue)
    }
    
    public func removingAll() -> TrieDictionary<Value> {
        return TrieDictionary<Value>()
    }
    
    public func removingAll(where shouldRemove: (Element) throws -> Bool) rethrows -> TrieDictionary<Value> {
        var newDict = TrieDictionary<Value>()
        for (key, value) in self {
            if try !shouldRemove((key: key, value: value)) {
                newDict.root = newDict.root.setting(key: key, value: value)
            }
        }
        return newDict
    }
    
    public func keepingOnly(where shouldKeep: (Element) throws -> Bool) rethrows -> TrieDictionary<Value> {
        var newDict = TrieDictionary<Value>()
        for (key, value) in self {
            if try shouldKeep((key: key, value: value)) {
                newDict.root = newDict.root.setting(key: key, value: value)
            }
        }
        return newDict
    }
}
