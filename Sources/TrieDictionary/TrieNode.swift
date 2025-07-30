import Foundation

internal struct TrieNode<Value> {
    private let value: Value?
    private let children: CompressedChildArray<Value>
    private let compressedPath: String
    
    init() {
        self.value = nil
        self.children = CompressedChildArray()
        self.compressedPath = ""
    }
    
    init(compressedPath: String) {
        self.value = nil
        self.children = CompressedChildArray()
        self.compressedPath = compressedPath
    }
    
    init(value: Value?, children: CompressedChildArray<Value>, compressedPath: String = "") {
        self.value = value
        self.children = children
        self.compressedPath = compressedPath
    }
    
    var isEmpty: Bool {
        value == nil && children.isEmpty
    }
    
    var nodeValue: Value? {
        return value
    }
    
    var nodeChildren: CompressedChildArray<Value> {
        return children
    }
    
    var count: Int {
        let selfCount = value != nil ? 1 : 0
        return selfCount + children.totalCount
    }
    
    func value(for key: String) -> Value? {
        return value(for: ArraySlice(key))
    }
    
    private func value(for key: ArraySlice<Character>) -> Value? {
        // Optimize: Compare ArraySlice directly without string conversion
        let compressedPathSlice = ArraySlice(compressedPath)
        
        // If the remaining key matches the compressed path exactly
        if key.elementsEqual(compressedPathSlice) {
            return value
        }
        
        // If the remaining key starts with the compressed path, consume it
        if key.starts(with: compressedPathSlice) {
            let newKey = key.dropFirst(compressedPathSlice.count)
            guard let childChar = newKey.first else { return value }
            guard let child = children.child(for: childChar) else { return nil }
            return child.value(for: newKey)
        }
        
        // Otherwise, no match
        return nil
    }
    
    func setting(key: String, value: Value) -> TrieNode<Value> {
        return setting(key: ArraySlice(key), value: value)
    }
    
    private func setting(key: ArraySlice<Character>, value: Value) -> TrieNode<Value> {
        let keyString = String(key)
        
        // Handle empty key - set value at current node
        if keyString.isEmpty {
            return TrieNode(value: value, children: children, compressedPath: compressedPath)
        }
        
        let compressedPathSlice = ArraySlice(compressedPath)
        let comparison = compareSlices(key, compressedPathSlice)
        if comparison == 0 {
            // Key exactly matches compressed path - set value here
            return TrieNode(value: value, children: children, compressedPath: compressedPath)
        }
        if comparison == 1 {
            // Key starts with our compressed path, consume it and continue
            let newKey = key.dropFirst(compressedPathSlice.count)
            let childChar = newKey.first!
            if let child = children.child(for: childChar) {
                let updatedChild = child.setting(key: newKey, value: value)
                let newChildren = children.setting(char: childChar, node: updatedChild)
                return TrieNode(value: self.value, children: newChildren, compressedPath: compressedPath)
            } else {
                // Create a new child with compressed path
                let newChild = TrieNode(value: value, children: CompressedChildArray(), compressedPath: String(newKey))
                let newChildren = children.setting(char: childChar, node: newChild)
                return TrieNode(value: self.value, children: newChildren, compressedPath: compressedPath)
            }
        }
        if comparison == 2 {
            // Our compressed path starts with the key, need to split
            let remainingPath = String(compressedPathSlice.dropFirst(key.count))
            let existingChild = TrieNode(value: self.value, children: children, compressedPath: remainingPath)
            let newChildren = CompressedChildArray<Value>().setting(char: remainingPath.first!, node: existingChild)
            return TrieNode(value: value, children: newChildren, compressedPath: String(key))
        }
        // Paths diverge, need to split at common prefix
        let common = commonPrefix(key, compressedPathSlice)
        let keyRemainder = String(key.dropFirst(common.count))
        let pathRemainder = String(compressedPathSlice.dropFirst(common.count))
        
        // Create child for existing path
        let existingChild = TrieNode(value: self.value, children: children, compressedPath: pathRemainder)
        var newChildren = CompressedChildArray<Value>().setting(char: pathRemainder.first!, node: existingChild)
        
        // Create child for new key
        let newChild = TrieNode(value: value, children: CompressedChildArray(), compressedPath: keyRemainder)
        newChildren = newChildren.setting(char: keyRemainder.first!, node: newChild)
        return TrieNode(value: nil, children: newChildren, compressedPath: common)
    }
    
    private func commonPrefix(_ str1: String, _ str2: String) -> String {
        return commonPrefix(ArraySlice(str1), ArraySlice(str2))
    }
    
    private func commonPrefix(_ slice1: ArraySlice<Character>, _ slice2: ArraySlice<Character>) -> String {
        // Optimize: Pre-allocate string capacity and avoid repeated memory allocations
        let maxLength = min(slice1.count, slice2.count)
        var result = ""
        result.reserveCapacity(maxLength)
        
        let pairs = zip(slice1, slice2)
        for (char1, char2) in pairs {
            if char1 == char2 {
                result.append(char1)
            } else {
                break
            }
        }
        
        return result
    }
    
    func removing(key: String) -> TrieNode<Value>? {
        return removing(keySlice: ArraySlice(key))
    }
    
    private func compareSlices(_ slice1: ArraySlice<Character>, _ slice2: ArraySlice<Character>) -> Int {
        if (slice1.elementsEqual(slice2)) { return 0 }
        if (slice1.starts(with: slice2)) { return 1 }
        if (slice2.starts(with: slice1)) { return 2 }
        else { return 3 }
    }
    
    private func removing(keySlice: ArraySlice<Character>) -> TrieNode<Value>? {
        let compressedPathSlice = ArraySlice(compressedPath)
        let comparison = compareSlices(keySlice, compressedPathSlice)
        if comparison == 0 {
            if children.childCount == 0 {
                return nil
            }
            if children.childCount == 1 {
                let child = children.firstChild!
                return Self(value: child.value, children: child.children, compressedPath: compressedPath + child.compressedPath)
            }
            return Self(value: nil, children: children, compressedPath: compressedPath)
        }
        if comparison == 1 {
            let newKey = keySlice.dropFirst(compressedPathSlice.count)
            let childChar = newKey.first!
            guard let child = children.child(for: childChar) else { return self }
            let newChild = child.removing(keySlice: newKey)
            if let newChild = newChild {
                let newChildren = children.setting(char: childChar, node: newChild)
                return Self(value: value, children: newChildren, compressedPath: compressedPath)
            }
            let newChildren = children.removing(char: childChar)
            if newChildren.childCount == 0 && value == nil {
                // Node has no value and no children - should be removed
                return nil
            }
            if newChildren.childCount == 1 && value == nil {
                let child = newChildren.firstChild!
                return Self(value: child.value, children: child.children, compressedPath: compressedPath + child.compressedPath)
            }
            return Self(value: value, children: newChildren, compressedPath: compressedPath)
            
        }
        return self
    }
    
    
    func allKeys() -> [String] {
        var keys: [String] = []
        collectKeys(prefix: "", into: &keys)
        return keys
    }
    
    func allValues() -> [Value] {
        var values: [Value] = []
        collectValues(into: &values)
        return values
    }
    
    private func collectKeys(prefix: String, into keys: inout [String]) {
        let fullPrefix = prefix + compressedPath
        
        if value != nil {
            keys.append(fullPrefix)
        }
        
        children.forEach { node in
            node.collectKeys(prefix: fullPrefix, into: &keys)
        }
    }
    
    private func collectValues(into values: inout [Value]) {
        if let value = value {
            values.append(value)
        }
        
        children.forEach { node in
            node.collectValues(into: &values)
        }
    }
    
    func traverse(prefix: String) -> CompressedChildArray<Value> {
        return traverse(prefix: ArraySlice(prefix))
    }
    
    private func traverse(prefix: ArraySlice<Character>) -> CompressedChildArray<Value> {
        let comparison = compareSlices(prefix, ArraySlice(compressedPath))
        
        if comparison == 0 {
            return children
        }
        if comparison == 1 {
            // Prefix starts with our compressed path - consume it and continue with children
            let remainingPrefix = prefix.dropFirst(compressedPath.count)
            let firstChar = remainingPrefix.first!
            guard let childNode = children.child(for: firstChar) else {
                return CompressedChildArray() // Empty subtrie
            }
            return childNode.traverse(prefix: remainingPrefix)
        }
        if comparison == 2 {
            // Our compressed path starts with the prefix - need to create a subtrie
            let remainingPath = String(compressedPath.dropFirst(prefix.count))
            return CompressedChildArray().setting(char: remainingPath.first!, node: TrieNode(value: value, children: children, compressedPath: remainingPath))
        }
        return CompressedChildArray()
    }
    
    func getValuesAlongPath(path: String) -> [Value] {
        var values: [Value] = []
        getValuesAlongPath(path: ArraySlice(path), values: &values)
        return values
    }
    
    private func getValuesAlongPath(path: ArraySlice<Character>, values: inout [Value]) {
        let comparison = compareSlices(path, ArraySlice(compressedPath))
        if comparison == 0 && value != nil {
            values.append(value!)
            return
        }
        if comparison == 1 {
            if value != nil {
                values.append(value!)
            }
            let remainingPath = path.dropFirst(compressedPath.count)
            let firstChar = remainingPath.first!
            guard let childNode = children.child(for: firstChar) else {
                return // Path doesn't exist
            }
            childNode.getValuesAlongPath(path: remainingPath, values: &values)
        }
    }
    
    
}

// MARK: - Testing Support
internal extension TrieNode {
    var isFullyCompressed: Bool {
        // Invariant 1: A node should not have no value and exactly one child
        // (such nodes should be merged with their single child)
        if value == nil && children.childCount == 1 {
            return false
        }
        
        // Invariant 2: A node should not have no children and no value
        // EXCEPT for the root node of an empty trie, which is valid
        if value == nil && children.childCount == 0 && !compressedPath.isEmpty {
            return false
        }
        
        // Check all children recursively
        var allChildrenCompressed = true
        children.forEach { childNode in
            if !childNode.isFullyCompressed {
                allChildrenCompressed = false
            }
        }
        
        return allChildrenCompressed
    }
    
    var hasValue: Bool {
        return value != nil
    }
    
    var childCount: Int {
        return children.childCount
    }
}
