import Foundation

/**
 Internal node structure for the compressed trie implementation.
 
 Each TrieNode represents a compressed path in the trie, containing:
 - An optional value (if this node represents the end of a key)
 - A compressed path string (representing a chain of characters)
 - Child nodes for continuing the trie structure
 
 ## Path Compression:
 Instead of storing single characters at each level, nodes store entire path segments.
 For example, if "application" is the only word starting with "app", the node will
 store "application" as a compressed path rather than creating separate nodes for
 "a", "p", "p", "l", "i", "c", "a", "t", "i", "o", "n".
 
 ## Performance Optimizations:
 - Method inlining for hot paths
 - ArraySlice usage to avoid string allocations
 - Efficient path splitting and merging algorithms
 */
internal struct TrieNode<Value> {
    /// The value stored at this node, if any
    private let value: Value?
    
    /// Child nodes organized in a compressed array for efficient lookup
    private let children: CompressedChildArray<Value>
    
    /// The compressed path segment stored at this node
    private let compressedPath: String
    
    /**
     Creates an empty node with no value, children, or compressed path.
     */
    init() {
        self.value = nil
        self.children = CompressedChildArray()
        self.compressedPath = ""
    }
    
    /**
     Creates a node with only a compressed path and no value or children.
     
     - Parameter compressedPath: The path segment to store at this node
     */
    init(compressedPath: String) {
        self.value = nil
        self.children = CompressedChildArray()
        self.compressedPath = compressedPath
    }
    
    /**
     Creates a node with the specified value, children, and compressed path.
     
     - Parameter value: The value to store at this node (nil if no value)
     - Parameter children: The child nodes
     - Parameter compressedPath: The compressed path segment
     */
    init(value: Value?, children: CompressedChildArray<Value>, compressedPath: String = "") {
        self.value = value
        self.children = children
        self.compressedPath = compressedPath
    }
    
    /**
     Returns `true` if this node has no value and no children.
     
     - Complexity: O(1)
     */
    @inline(__always)
    var isEmpty: Bool {
        value == nil && children.isEmpty
    }
    
    /**
     Returns the value stored at this node.
     
     - Returns: The value, or `nil` if no value is stored
     - Complexity: O(1)
     */
    @inline(__always)
    var nodeValue: Value? {
        return value
    }
    
    /**
     Returns the compressed child array for this node.
     
     - Returns: The child nodes structure
     - Complexity: O(1)
     */
    @inline(__always)
    var nodeChildren: CompressedChildArray<Value> {
        return children
    }
    
    
    @inline(__always)
    var nodePath: String {
        return compressedPath
    }
    
    /**
     Returns the total number of values stored in this subtree.
     
     This includes the value at this node (if any) plus all values in child nodes.
     
     - Returns: The total count of values in this subtree
     - Complexity: O(n) where n is the number of nodes in the subtree
     */
    var count: Int {
        let selfCount = value != nil ? 1 : 0
        return selfCount + children.totalCount
    }
    
    /**
     Retrieves the value associated with the given key in this subtree.
     
     - Parameter key: The key to search for
     - Returns: The associated value, or `nil` if not found
     - Complexity: O(k) where k is the length of the key
     */
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
    
    /**
     Returns a new node with the given key-value pair added or updated.
     
     This method implements path compression by potentially splitting nodes
     when new keys diverge from existing compressed paths.
     
     - Parameter key: The key to add or update
     - Parameter value: The value to associate with the key
     - Returns: A new TrieNode representing the updated subtree
     - Complexity: O(k) where k is the length of the key
     */
    func setting(key: String, value: Value) -> TrieNode<Value> {
        return setting(key: ArraySlice(key), value: value)
    }
    
    private func setting(key: ArraySlice<Character>, value: Value) -> TrieNode<Value> {
        // Handle empty key - set value at current node
        if key.isEmpty {
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
        let common = commonPrefixString(key, compressedPathSlice)
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
    
    @inline(__always)
    private func commonPrefix(_ str1: String, _ str2: String) -> String {
        return commonPrefix(ArraySlice(str1), ArraySlice(str2))
    }
    
    @inline(__always) 
    private func commonPrefixString(_ slice1: ArraySlice<Character>, _ slice2: ArraySlice<Character>) -> String {
        return commonPrefix(slice1, slice2)
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
    
    /**
     Returns a new node with the given key removed, or `nil` if the node becomes empty.
     
     This method handles path compression by potentially merging nodes when
     a removal operation leaves a node with only one child and no value.
     
     - Parameter key: The key to remove
     - Returns: A new TrieNode without the key, or `nil` if the subtree becomes empty
     - Complexity: O(k) where k is the length of the key
     */
    func removing(key: String) -> TrieNode<Value>? {
        return removing(keySlice: ArraySlice(key))
    }
    
    @inline(__always)
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
    
    
    /**
     Returns all keys stored in this subtree.
     
     The keys are collected by traversing the entire subtree and building
     complete key strings from the compressed path segments.
     
     - Returns: An array of all keys in this subtree
     - Complexity: O(n*m) where n is the number of keys and m is the average key length
     */
    func allKeys() -> [String] {
        var keys: [String] = []
        collectKeys(prefix: "", into: &keys)
        return keys
    }
    
    /**
     Returns all values stored in this subtree.
     
     - Returns: An array of all values in this subtree
     - Complexity: O(n) where n is the number of values
     */
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
    
    /**
     Returns the compressed child array representing the subtree at the given prefix.
     
     This method navigates to the end of the prefix path and returns the child array
     from that point, effectively creating a subtrie rooted at the prefix.
     
     - Parameter prefix: The prefix to traverse to
     - Returns: The compressed child array at the prefix location
     - Complexity: O(k) where k is the length of the prefix
     */
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
    
    /**
     Returns all values encountered while traversing the given path.
     
     This method collects values from all nodes visited during path traversal,
     not just the final destination. Useful for hierarchical data access.
     
     - Parameter path: The path to traverse
     - Returns: An array of values found along the path
     - Complexity: O(k) where k is the length of the path
     */
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
    
    /**
     Returns a new node that merges this node with another node.
     
     This method handles merging of compressed paths, values, and child nodes.
     When both nodes have values, the merge rule determines the result.
     When compressed paths differ, they are properly aligned and merged.
     
     - Parameter other: The other TrieNode to merge with
     - Parameter mergeRule: A closure that resolves conflicts when both nodes have values
     - Returns: A new merged TrieNode
     - Complexity: O(m + n) where m and n are the sizes of the child arrays
     */
    func merging(with other: TrieNode<Value>, mergeRule: (Value, Value) -> Value) -> TrieNode<Value> {
        let selfPathSlice = ArraySlice(compressedPath)
        let otherPathSlice = ArraySlice(other.compressedPath)
        
        let comparison = compareSlices(selfPathSlice, otherPathSlice)
                
        if comparison == 0 {
            let mergedValues = value != nil ? (other.value != nil ? mergeRule(value!, other.value!) : value) : other.value
            return Self(value: mergedValues, children: children.merging(with: other.children, mergeRule: { $0.merging(with: $1, mergeRule: mergeRule) }), compressedPath: compressedPath)
        }
        if comparison == 1 {
            let selfRemainder = selfPathSlice.dropFirst(otherPathSlice.count)
            let selfChar = selfRemainder.first!
            let selfChild = TrieNode(value: value, children: children, compressedPath: String(selfRemainder))
            if let otherChild = other.children.child(for: selfChar) {
                let newChildren = other.children.setting(char: selfChar, node: selfChild.merging(with: otherChild, mergeRule: mergeRule))
                return Self(value: other.value, children: newChildren, compressedPath: other.compressedPath)
            }
            let newChildren = other.children.setting(char: selfChar, node: selfChild)
            return Self(value: other.value, children: newChildren, compressedPath: other.compressedPath)
        }
        if comparison == 2 {
            let otherRemainder = otherPathSlice.dropFirst(selfPathSlice.count)
            let otherChar = otherRemainder.first!
            let otherChild = TrieNode(value: other.value, children: other.children, compressedPath: String(otherRemainder))
            if let selfChild = children.child(for: otherChar) {
                let newChldren = children.setting(char: otherChar, node: selfChild.merging(with: otherChild, mergeRule: mergeRule))
                return Self(value: value, children: newChldren, compressedPath: compressedPath)
            }
            let newChldren = children.setting(char: otherChar, node: otherChild)
            return Self(value: value, children: newChldren, compressedPath: compressedPath)
        }
        let commonPrefix = commonPrefix(otherPathSlice, selfPathSlice)
        let selfRemainder = selfPathSlice.dropFirst(commonPrefix.count)
        let otherRemainder = otherPathSlice.dropFirst(commonPrefix.count)
        let selfChar = selfRemainder.first!
        let otherChar = otherRemainder.first!
        let newChildren = CompressedChildArray().setting(char: selfChar, node: Self(value: value, children: children, compressedPath: String(selfRemainder))).setting(char: otherChar, node: Self(value: other.value, children: other.children, compressedPath: String(otherRemainder)))
        return Self(value: nil, children: newChildren, compressedPath: commonPrefix)
    }
    
}

// MARK: - Testing Support
internal extension TrieNode {
    /**
     Returns `true` if this node and all its descendants maintain proper compression invariants.
     
     A properly compressed node satisfies:
     - If it has no value and exactly one child, it should be merged with that child
     - If it has no value and no children, it should only exist as an empty root
     
     This property is used for testing and debugging trie compression.
     
     - Returns: `true` if the subtree is properly compressed
     - Complexity: O(n) where n is the number of nodes in the subtree
     */
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
    
    /**
     Returns `true` if this node stores a value.
     
     - Returns: `true` if a value is stored at this node
     - Complexity: O(1)
     */
    var hasValue: Bool {
        return value != nil
    }
    
    /**
     Returns the number of direct child nodes.
     
     - Returns: The count of child nodes
     - Complexity: O(1)
     */
    var childCount: Int {
        return children.childCount
    }
}
