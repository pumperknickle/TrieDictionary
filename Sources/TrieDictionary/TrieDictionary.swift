import Foundation

/**
 A high-performance compressed trie (prefix tree) implementation that provides Dictionary-like
 functionality with advanced path-based operations.
 
 A TrieDictionary stores key-value pairs where keys are strings, using a compressed trie structure
 that minimizes memory usage by merging chains of single-child nodes. This makes it particularly
 efficient for datasets with common prefixes.
 
 ## Key Features:
 - **Memory Efficient**: Path compression reduces memory overhead
 - **Fast Operations**: O(k) lookup, insertion, and deletion where k = key length
 - **Advanced Traversal**: Built-in support for prefix-based operations
 - **Functional Operations**: Methods for transforming keys with prefixes/suffixes
 - **High Performance**: Optimized for speed with method inlining and efficient data structures
 
 ## Usage:
 ```swift
 var trie = TrieDictionary<String>()
 trie["apple"] = "fruit"
 trie["application"] = "software"
 trie["apply"] = "action"
 
 // Traverse by prefix
 let appTrie = trie.traverse("app")
 
 // Get values along a path
 let values = trie.getValuesAlongPath("application")
 ```
 
 ## Performance Characteristics:
 - **Insertion**: O(k) where k is the key length
 - **Lookup**: O(k) where k is the key length
 - **Deletion**: O(k) where k is the key length
 - **Memory**: O(n*m) where n is number of keys, m is average unique prefix length
 
 - Note: Path compression significantly reduces memory usage for datasets with common prefixes
 */
public struct TrieDictionary<Value> {
    /// The root children array containing the compressed trie structure
    private var children: CompressedChildArray<Value>
    
    /**
     Creates an empty TrieDictionary.
     
     - Complexity: O(1)
     */
    public init() {
        self.children = CompressedChildArray()
    }
    
    /**
     Internal initializer for creating a TrieDictionary with existing children.
     Used for efficient subtrie operations.
     
     - Parameter children: The compressed child array to use as the root
     */
    init(_ children: CompressedChildArray<Value>) {
        self.children = children
    }
    
    /**
     Returns `true` if the trie contains no key-value pairs.
     
     - Complexity: O(1)
     */
    @inline(__always)
    public var isEmpty: Bool {
        children.isEmpty
    }
    
    /**
     The number of key-value pairs stored in the trie.
     
     - Complexity: O(n) where n is the number of nodes in the trie
     - Note: This traverses the entire trie structure to count values
     */
    public var count: Int {
        return children.totalCount
    }
    
    /**
     Accesses the value associated with the given key for reading and writing.
     
     Use this subscript to retrieve values from the trie or to add, update, or remove values:
     
     ```swift
     var trie = TrieDictionary<String>()
     trie["hello"] = "world"      // Insert
     print(trie["hello"])         // Retrieve: Optional("world")
     trie["hello"] = "universe"   // Update
     trie["hello"] = nil          // Remove
     ```
     
     - Parameter key: The string key to look up or modify
     - Returns: The value associated with the key, or `nil` if no value exists
     - Complexity: O(k) where k is the length of the key
     */
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
    
    /**
     Returns an array containing all keys in the trie.
     
     The order of keys in the returned array is determined by the trie's internal structure
     and may not be alphabetically sorted.
     
     ```swift
     var trie = TrieDictionary<Int>()
     trie["apple"] = 1
     trie["banana"] = 2
     let allKeys = trie.keys() // ["apple", "banana"]
     ```
     
     - Returns: An array of all keys in the trie
     - Complexity: O(n*m) where n is the number of keys and m is the average key length
     */
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
    
    /**
     Returns an array containing all values in the trie.
     
     The order of values corresponds to the order of their associated keys as returned by `keys()`.
     
     ```swift
     var trie = TrieDictionary<String>()
     trie["apple"] = "red"
     trie["banana"] = "yellow"
     let allValues = trie.values() // ["red", "yellow"]
     ```
     
     - Returns: An array of all values in the trie
     - Complexity: O(n) where n is the number of key-value pairs
     */
    public func values() -> [Value] {
        var values: [Value] = []
        children.forEach { node in
            let childValues = node.allValues()
            values.append(contentsOf: childValues)
        }
        return values
    }
    
    /**
     Returns a new TrieDictionary containing all key-value pairs whose keys start with the given prefix.
     
     This creates a subtrie rooted at the end of the prefix path. Keys in the returned trie
     will have the prefix removed.
     
     ```swift
     var trie = TrieDictionary<String>()
     trie["apple"] = "fruit"
     trie["application"] = "software"
     trie["apply"] = "action"
     
     let appTrie = trie.traverse("app")
     // appTrie contains: "le" -> "fruit", "lication" -> "software", "ly" -> "action"
     ```
     
     - Parameter prefix: The prefix to search for
     - Returns: A new TrieDictionary containing matching key-value pairs with prefix removed
     - Complexity: O(k) where k is the length of the prefix
     */
    public func traverse(_ prefix: String) -> TrieDictionary<Value> {
        guard let firstChar = prefix.first else { return self }
        guard let child = children.child(for: firstChar) else { return Self() }
        return Self(child.traverse(prefix: prefix))
    }
    
    
    /**
     Returns an array of all values found along the path from root to the given key.
     
     This method collects values from all nodes encountered while traversing the path,
     not just the final destination. Useful for hierarchical data structures.
     
     ```swift
     var trie = TrieDictionary<String>()
     trie["a"] = "first"
     trie["app"] = "second"
     trie["apple"] = "third"
     
     let values = trie.getValuesAlongPath("apple")
     // values = ["first", "second", "third"]
     ```
     
     - Parameter path: The path to traverse
     - Returns: An array of values encountered along the path
     - Complexity: O(k) where k is the length of the path
     */
    public func getValuesAlongPath(_ path: String) -> [Value] {
        guard let firstChar = path.first else { return [] }
        guard let child = children.child(for: firstChar) else { return [] }
        return child.getValuesAlongPath(path: path)
    }
    
    /**
     Updates the value stored in the trie for the given key, or adds a new key-value pair if the key doesn't exist.
     
     ```swift
     var trie = TrieDictionary<String>()
     let oldValue = trie.updateValue("world", forKey: "hello") // nil
     let previousValue = trie.updateValue("universe", forKey: "hello") // "world"
     ```
     
     - Parameter value: The value to associate with the key
     - Parameter key: The key to update
     - Returns: The previous value associated with the key, or `nil` if the key was not present
     - Complexity: O(k) where k is the length of the key
     */
    @discardableResult
    public mutating func updateValue(_ value: Value, forKey key: String) -> Value? {
        let oldValue = self[key]
        self[key] = value
        return oldValue
    }
    
    /**
     Removes the value for the given key and returns the removed value, or `nil` if the key was not present.
     
     ```swift
     var trie = TrieDictionary<String>()
     trie["hello"] = "world"
     let removed = trie.removeValue(forKey: "hello") // "world"
     let notFound = trie.removeValue(forKey: "missing") // nil
     ```
     
     - Parameter key: The key to remove
     - Returns: The value that was removed, or `nil` if the key was not present
     - Complexity: O(k) where k is the length of the key
     */
    @discardableResult
    public mutating func removeValue(forKey key: String) -> Value? {
        let oldValue = self[key]
        self[key] = nil
        return oldValue
    }
    
    /**
     Removes all key-value pairs from the trie.
     
     ```swift
     var trie = TrieDictionary<String>()
     trie["key1"] = "value1"
     trie["key2"] = "value2"
     trie.removeAll()
     print(trie.isEmpty) // true
     ```
     
     - Complexity: O(1)
     */
    public mutating func removeAll() {
        children = CompressedChildArray()
    }
    
    // MARK: - Functional Traverse and Path Operations
    
    /**
     Returns a new TrieDictionary where all keys are prefixed with the given string.
     
     This creates a new trie where every key from the original trie is prefixed with the
     specified string. The original trie remains unchanged.
     
     ```swift
     var trie = TrieDictionary<String>()
     trie["apple"] = "fruit"
     trie["tree"] = "plant"
     
     let prefixed = trie.addingPrefix("my_")
     // prefixed contains: "my_apple" -> "fruit", "my_tree" -> "plant"
     ```
     
     - Parameter prefix: The string to prepend to all keys
     - Returns: A new TrieDictionary with prefixed keys
     - Complexity: O(n*m) where n is the number of keys and m is the average key length
     */
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
    
    /**
     Returns a new TrieDictionary where all keys have the given suffix added.
     
     This creates a new trie where every key from the original trie has the specified
     string appended to it. The original trie remains unchanged.
     
     ```swift
     var trie = TrieDictionary<String>()
     trie["apple"] = "fruit"
     trie["tree"] = "plant"
     
     let suffixed = trie.addingSuffix("_item")
     // suffixed contains: "apple_item" -> "fruit", "tree_item" -> "plant"
     ```
     
     - Parameter suffix: The string to append to all keys
     - Returns: A new TrieDictionary with suffixed keys
     - Complexity: O(n*m) where n is the number of keys and m is the average key length
     */
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
    
    /**
     Returns a new TrieDictionary where keys have the specified prefix removed.
     
     Only keys that start with the given prefix are transformed; other keys are kept unchanged.
     Keys that would become empty after prefix removal are excluded from the result.
     
     ```swift
     var trie = TrieDictionary<String>()
     trie["com.example.app"] = "app"
     trie["com.example.lib"] = "library"
     trie["other.item"] = "other"
     
     let trimmed = trie.removingPrefix("com.example.")
     // trimmed contains: "app" -> "app", "lib" -> "library", "other.item" -> "other"
     ```
     
     - Parameter prefix: The prefix to remove from keys
     - Returns: A new TrieDictionary with prefix removed from matching keys
     - Complexity: O(n*m) where n is the number of keys and m is the average key length
     */
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
    
    /**
     Returns a new TrieDictionary where keys have the specified suffix removed.
     
     Only keys that end with the given suffix are transformed; other keys are kept unchanged.
     Keys that would become empty after suffix removal are excluded from the result.
     
     ```swift
     var trie = TrieDictionary<String>()
     trie["file.txt"] = "text"
     trie["image.txt"] = "image"
     trie["other.doc"] = "document"
     
     let trimmed = trie.removingSuffix(".txt")
     // trimmed contains: "file" -> "text", "image" -> "image", "other.doc" -> "document"
     ```
     
     - Parameter suffix: The suffix to remove from keys
     - Returns: A new TrieDictionary with suffix removed from matching keys
     - Complexity: O(n*m) where n is the number of keys and m is the average key length
     */
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
    
    /**
     Returns a TrieDictionary mapping paths to arrays of values found along each path.
     
     For each path in the input array, this method collects all values encountered while
     traversing from the root to that path, similar to `getValuesAlongPath` but for multiple paths.
     
     ```swift
     var trie = TrieDictionary<String>()
     trie["a"] = "first"
     trie["app"] = "second"
     trie["apple"] = "third"
     
     let gathered = trie.gatheringValuesAlongPaths(["apple", "app"])
     // gathered contains: "apple" -> ["first", "second", "third"], "app" -> ["first", "second"]
     ```
     
     - Parameter paths: An array of paths to traverse
     - Returns: A TrieDictionary mapping each path to its collected values
     - Complexity: O(p*k) where p is the number of paths and k is the average path length
     */
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
    
    /**
     Returns a TrieDictionary where each existing key maps to all values found along its path.
     
     This transforms the trie so that each key-value pair becomes a key-array pair,
     where the array contains all values encountered while traversing from root to that key.
     
     ```swift
     var trie = TrieDictionary<String>()
     trie["a"] = "first"
     trie["app"] = "second"
     trie["apple"] = "third"
     
     let expanded = trie.expandingToPathValues()
     // expanded contains:
     // "a" -> ["first"]
     // "app" -> ["first", "second"]
     // "apple" -> ["first", "second", "third"]
     ```
     
     - Returns: A TrieDictionary where values are arrays of path values
     - Complexity: O(n*k) where n is the number of keys and k is the average key length
     */
    public func expandingToPathValues() -> TrieDictionary<[Value]> {
        var result = TrieDictionary<[Value]>()
        for (key, _) in self {
            let pathValues = getValuesAlongPath(key)
            result[key] = pathValues
        }
        return result
    }
    
    /**
     Returns a new TrieDictionary containing only the subtrie at the given prefix.
     
     This is equivalent to `traverse(_:)` and creates a subtrie rooted at the end of the prefix path.
     Keys in the returned trie will have the prefix removed.
     
     ```swift
     var trie = TrieDictionary<String>()
     trie["prefix_apple"] = "fruit"
     trie["prefix_tree"] = "plant"
     trie["other"] = "item"
     
     let sub = trie.subtrie(at: "prefix_")
     // sub contains: "apple" -> "fruit", "tree" -> "plant"
     ```
     
     - Parameter prefix: The prefix to use as the root of the subtrie
     - Returns: A new TrieDictionary containing the subtrie
     - Complexity: O(k) where k is the length of the prefix
     */
    public func subtrie(at prefix: String) -> TrieDictionary<Value> {
        return traverse(prefix)
    }
    
    /**
     Returns multiple subtries for the given prefixes.
     
     This method creates a TrieDictionary where each key is a prefix and each value is the
     corresponding subtrie. Only non-empty subtries are included in the result.
     
     ```swift
     var trie = TrieDictionary<String>()
     trie["com.apple.app"] = "iOS"
     trie["com.google.search"] = "web"
     trie["org.swift.lang"] = "language"
     
     let subs = trie.subtries(at: ["com.apple.", "com.google."])
     // subs contains:
     // "com.apple." -> TrieDictionary with "app" -> "iOS"
     // "com.google." -> TrieDictionary with "search" -> "web"
     ```
     
     - Parameter prefixes: An array of prefixes to create subtries for
     - Returns: A TrieDictionary mapping prefixes to their subtries
     - Complexity: O(p*k) where p is the number of prefixes and k is the average prefix length
     */
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
    /**
     Returns `true` if the trie is in a fully compressed state.
     
     A fully compressed trie satisfies these invariants:
     - No node has exactly one child with no value (such nodes should be merged)
     - No node has no children and no value (except for empty tries)
     
     This property is primarily used for testing and debugging to ensure the trie
     maintains its compressed structure after operations.
     
     - Returns: `true` if the trie structure is properly compressed
     - Complexity: O(n) where n is the number of nodes
     */
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
