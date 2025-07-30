import Foundation

public struct TrieDictionary<Value> {
    private var children: CompressedChildArray<Value>
    
    public init() {
        self.children = CompressedChildArray()
    }
    
    init(_ children: CompressedChildArray<Value>) {
        self.children = children
    }
    
    @inline(__always)
    public var isEmpty: Bool {
        children.isEmpty
    }
    
    public var count: Int {
        return children.totalCount
    }
    
    public subscript(key: String) -> Value? {
        get {
            guard let firstChar = key.first else { return nil }
            guard let child = children.child(for: firstChar) else { return nil }
            return child.value(for: key)
        }
        set {
            guard let firstChar = key.first else { return }
            if let newValue = newValue {
                if let existingChild = children.child(for: firstChar) {
                    let updatedChild = existingChild.setting(key: key, value: newValue)
                    children = children.setting(char: firstChar, node: updatedChild)
                } else {
                    let newChild = TrieNode(value: newValue, children: CompressedChildArray(), compressedPath: key)
                    children = children.setting(char: firstChar, node: newChild)
                }
            }
            else {
                if let existingChild = children.child(for: firstChar) {
                    if let updatedChild = existingChild.removing(key: key) {
                        children = children.setting(char: firstChar, node: updatedChild)
                    } else {
                        children = children.removing(char: firstChar)
                    }
                }
            }
        }
    }
    
    public func keys() -> [String] {
        var keys: [String] = []
        children.forEach { node in
            let childKeys = node.allKeys()
            for childKey in childKeys {
                keys.append(childKey)
            }
        }
        return keys
    }
    
    public func values() -> [Value] {
        var values: [Value] = []
        children.forEach { node in
            let childValues = node.allValues()
            values.append(contentsOf: childValues)
        }
        return values
    }
    
    public func traverse(_ prefix: String) -> TrieDictionary<Value> {
        guard let firstChar = prefix.first else { return self }
        guard let child = children.child(for: firstChar) else { return Self() }
        return Self(child.traverse(prefix: prefix))
    }
    
    
    public func getValuesAlongPath(_ path: String) -> [Value] {
        guard let firstChar = path.first else { return [] }
        guard let child = children.child(for: firstChar) else { return [] }
        return child.getValuesAlongPath(path: path)
    }
    
    @discardableResult
    public mutating func updateValue(_ value: Value, forKey key: String) -> Value? {
        let oldValue = self[key]
        self[key] = value
        return oldValue
    }
    
    @discardableResult
    public mutating func removeValue(forKey key: String) -> Value? {
        let oldValue = self[key]
        self[key] = nil
        return oldValue
    }
    
    public mutating func removeAll() {
        children = CompressedChildArray()
    }
    
    // MARK: - Functional Traverse and Path Operations
    
    /// Returns a new TrieDictionary where all keys are prefixed with the given string
    public func addingPrefix(_ prefix: String) -> TrieDictionary<Value> {
        guard !prefix.isEmpty else { return self }
        var result = TrieDictionary<Value>()
        let prefixCapacity = prefix.count
        for (key, value) in self {
            var newKey = String()
            newKey.reserveCapacity(prefixCapacity + key.count)
            newKey.append(prefix)
            newKey.append(key)
            result[newKey] = value
        }
        return result
    }
    
    /// Returns a new TrieDictionary where all keys have the given suffix added
    public func addingSuffix(_ suffix: String) -> TrieDictionary<Value> {
        guard !suffix.isEmpty else { return self }
        var result = TrieDictionary<Value>()
        let suffixCapacity = suffix.count
        for (key, value) in self {
            var newKey = String()
            newKey.reserveCapacity(key.count + suffixCapacity)
            newKey.append(key)
            newKey.append(suffix)
            result[newKey] = value
        }
        return result
    }
    
    /// Returns a new TrieDictionary where all keys are transformed by removing a common prefix
    public func removingPrefix(_ prefix: String) -> TrieDictionary<Value> {
        guard !prefix.isEmpty else { return self }
        var result = TrieDictionary<Value>()
        for (key, value) in self {
            if key.hasPrefix(prefix) {
                let newKey = String(key.dropFirst(prefix.count))
                if !newKey.isEmpty {  // Don't add empty keys
                    result[newKey] = value
                }
            } else {
                result[key] = value  // Keep keys that don't have the prefix
            }
        }
        return result
    }
    
    /// Returns a new TrieDictionary where all keys are transformed by removing a common suffix
    public func removingSuffix(_ suffix: String) -> TrieDictionary<Value> {
        guard !suffix.isEmpty else { return self }
        var result = TrieDictionary<Value>()
        for (key, value) in self {
            if key.hasSuffix(suffix) {
                let newKey = String(key.dropLast(suffix.count))
                if !newKey.isEmpty {  // Don't add empty keys
                    result[newKey] = value
                }
            } else {
                result[key] = value  // Keep keys that don't have the suffix
            }
        }
        return result
    }
    
    /// Returns a TrieDictionary containing values found along multiple paths
    public func gatheringValuesAlongPaths(_ paths: [String]) -> TrieDictionary<[Value]> {
        var result = TrieDictionary<[Value]>()
        for path in paths {
            let values = getValuesAlongPath(path)
            if !values.isEmpty {
                result[path] = values
            }
        }
        return result
    }
    
    /// Returns a TrieDictionary where each key maps to all the values found along its path
    public func expandingToPathValues() -> TrieDictionary<[Value]> {
        var result = TrieDictionary<[Value]>()
        for (key, _) in self {
            let pathValues = getValuesAlongPath(key)
            result[key] = pathValues
        }
        return result
    }
    
    /// Returns a new TrieDictionary containing only the subtrie at the given prefix, with keys adjusted
    public func subtrie(at prefix: String) -> TrieDictionary<Value> {
        return traverse(prefix)
    }
    
    /// Returns multiple subtries for the given prefixes
    public func subtries(at prefixes: [String]) -> TrieDictionary<TrieDictionary<Value>> {
        var result = TrieDictionary<TrieDictionary<Value>>()
        for prefix in prefixes {
            let subtrie = traverse(prefix)
            if !subtrie.isEmpty {
                result[prefix] = subtrie
            }
        }
        return result
    }
    
}

// MARK: - Testing Support
extension TrieDictionary {
    public var isFullyCompressed: Bool {
        var allChildrenCompressed = true
        children.forEach { childNode in
            if !childNode.isFullyCompressed {
                allChildrenCompressed = false
            }
        }
        return allChildrenCompressed
    }
}
