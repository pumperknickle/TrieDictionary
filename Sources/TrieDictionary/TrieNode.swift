import Foundation

internal struct TrieNode<Value> {
    private let value: Value?
    private let isTerminal: Bool
    private let children: CompressedChildArray<Value>
    
    init() {
        self.value = nil
        self.isTerminal = false
        self.children = CompressedChildArray()
    }
    
    private init(value: Value?, isTerminal: Bool, children: CompressedChildArray<Value>) {
        self.value = value
        self.isTerminal = isTerminal
        self.children = children
    }
    
    var isEmpty: Bool {
        !isTerminal && children.isEmpty
    }
    
    var count: Int {
        let selfCount = isTerminal ? 1 : 0
        return selfCount + children.totalCount
    }
    
    func value(for key: String) -> Value? {
        return value(for: key, startIndex: key.startIndex)
    }
    
    private func value(for key: String, startIndex: String.Index) -> Value? {
        if startIndex == key.endIndex {
            return isTerminal ? value : nil
        }
        
        let char = key[startIndex]
        guard let childNode = children.child(for: char) else {
            return nil
        }
        
        let nextIndex = key.index(after: startIndex)
        return childNode.value(for: key, startIndex: nextIndex)
    }
    
    func setting(key: String, value: Value) -> TrieNode<Value> {
        return setting(key: key, value: value, startIndex: key.startIndex)
    }
    
    private func setting(key: String, value: Value, startIndex: String.Index) -> TrieNode<Value> {
        if startIndex == key.endIndex {
            return TrieNode(value: value, isTerminal: true, children: children)
        }
        
        let char = key[startIndex]
        let nextIndex = key.index(after: startIndex)
        
        let existingChild = children.child(for: char) ?? TrieNode()
        let updatedChild = existingChild.setting(key: key, value: value, startIndex: nextIndex)
        let updatedChildren = children.setting(char: char, node: updatedChild)
        
        return TrieNode(value: self.value, isTerminal: isTerminal, children: updatedChildren)
    }
    
    func removing(key: String) -> TrieNode<Value> {
        return removing(key: key, startIndex: key.startIndex)
    }
    
    private func removing(key: String, startIndex: String.Index) -> TrieNode<Value> {
        if startIndex == key.endIndex {
            if !isTerminal {
                return self
            }
            return TrieNode(value: nil, isTerminal: false, children: children)
        }
        
        let char = key[startIndex]
        guard let existingChild = children.child(for: char) else {
            return self
        }
        
        let nextIndex = key.index(after: startIndex)
        let updatedChild = existingChild.removing(key: key, startIndex: nextIndex)
        
        if updatedChild.isEmpty {
            let updatedChildren = children.removing(char: char)
            return TrieNode(value: self.value, isTerminal: isTerminal, children: updatedChildren)
        } else {
            let updatedChildren = children.setting(char: char, node: updatedChild)
            return TrieNode(value: self.value, isTerminal: isTerminal, children: updatedChildren)
        }
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
        if isTerminal {
            keys.append(prefix)
        }
        
        children.forEach { char, node in
            let newPrefix = prefix + String(char)
            node.collectKeys(prefix: newPrefix, into: &keys)
        }
    }
    
    private func collectValues(into values: inout [Value]) {
        if isTerminal, let value = value {
            values.append(value)
        }
        
        children.forEach { _, node in
            node.collectValues(into: &values)
        }
    }
    
    func traverse(prefix: String) -> TrieNode<Value> {
        return traverse(prefix: ArraySlice(prefix))
    }
    
    private func traverse(prefix: ArraySlice<Character>) -> TrieNode<Value> {
        guard let firstChar = prefix.first else {
            return self
        }
        
        guard let childNode = children.child(for: firstChar) else {
            return TrieNode()
        }
        
        let suffix = prefix.dropFirst()
        return childNode.traverse(prefix: suffix)
    }
}