import Foundation

internal struct TrieNode<Value> {
    private let value: Value?
    private let isTerminal: Bool
    private let children: CompressedChildArray<Value>
    private let compressedPath: String
    
    init() {
        self.value = nil
        self.isTerminal = false
        self.children = CompressedChildArray()
        self.compressedPath = ""
    }
    
    private init(value: Value?, isTerminal: Bool, children: CompressedChildArray<Value>, compressedPath: String = "") {
        self.value = value
        self.isTerminal = isTerminal
        self.children = children
        self.compressedPath = compressedPath
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
        // Handle compressed path
        if !compressedPath.isEmpty {
            let remainingKey = String(key[startIndex...])
            
            // If the remaining key matches the compressed path exactly
            if remainingKey == compressedPath {
                return isTerminal ? value : nil
            }
            
            // If the remaining key starts with the compressed path, consume it
            if remainingKey.hasPrefix(compressedPath) {
                let newStartIndex = key.index(startIndex, offsetBy: compressedPath.count)
                return value(for: key, startIndex: newStartIndex)
            }
            
            // Otherwise, no match
            return nil
        }
        
        // If we've consumed the entire key
        if startIndex == key.endIndex {
            return isTerminal ? value : nil
        }
        
        // Continue traversing children
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
        // For now, let's use a simpler approach without complex path compression during insertion
        // Handle compressed path by consuming it if the key matches
        if !compressedPath.isEmpty {
            let remainingKey = String(key[startIndex...])
            if remainingKey.hasPrefix(compressedPath) {
                let newStartIndex = key.index(startIndex, offsetBy: compressedPath.count)
                return setting(key: key, value: value, startIndex: newStartIndex)
            } else {
                // For now, just return self - more complex splitting logic can be added later
                return self
            }
        }
        
        if startIndex == key.endIndex {
            return TrieNode(value: value, isTerminal: true, children: children, compressedPath: compressedPath)
        }
        
        let char = key[startIndex]
        let nextIndex = key.index(after: startIndex)
        
        let existingChild = children.child(for: char) ?? TrieNode()
        let updatedChild = existingChild.setting(key: key, value: value, startIndex: nextIndex)
        let updatedChildren = children.setting(char: char, node: updatedChild)
        
        return TrieNode(value: self.value, isTerminal: isTerminal, children: updatedChildren, compressedPath: compressedPath)
    }
    
    private func commonPrefix(_ str1: String, _ str2: String) -> String {
        var result = ""
        let minLength = min(str1.count, str2.count)
        
        for i in 0..<minLength {
            let idx1 = str1.index(str1.startIndex, offsetBy: i)
            let idx2 = str2.index(str2.startIndex, offsetBy: i)
            
            if str1[idx1] == str2[idx2] {
                result.append(str1[idx1])
            } else {
                break
            }
        }
        
        return result
    }
    
    func removing(key: String) -> TrieNode<Value> {
        return removing(key: key, startIndex: key.startIndex)
    }
    
    private func removing(key: String, startIndex: String.Index) -> TrieNode<Value> {
        let remainingKey = String(key[startIndex...])
        
        if !compressedPath.isEmpty {
            if remainingKey.hasPrefix(compressedPath) {
                let newStartIndex = key.index(startIndex, offsetBy: compressedPath.count)
                return removing(key: key, startIndex: newStartIndex)
            } else {
                return self
            }
        }
        
        if startIndex == key.endIndex {
            if !isTerminal {
                return self
            }
            // Just remove the terminal flag and value, keep children
            return TrieNode(value: nil, isTerminal: false, children: children, compressedPath: compressedPath)
        }
        
        let char = key[startIndex]
        guard let existingChild = children.child(for: char) else {
            return self
        }
        
        let nextIndex = key.index(after: startIndex)
        let updatedChild = existingChild.removing(key: key, startIndex: nextIndex)
        
        if updatedChild.isEmpty {
            let updatedChildren = children.removing(char: char)
            return TrieNode(value: self.value, isTerminal: isTerminal, children: updatedChildren, compressedPath: compressedPath)
        } else {
            let updatedChildren = children.setting(char: char, node: updatedChild)
            return TrieNode(value: self.value, isTerminal: isTerminal, children: updatedChildren, compressedPath: compressedPath)
        }
    }
    
    private func compressIfNeeded(_ node: TrieNode<Value>) -> TrieNode<Value> {
        if !node.isTerminal && node.children.childCount == 1 && node.value == nil {
            if let (singleChar, singleChild) = node.children.firstChild {
                let newCompressedPath = node.compressedPath + String(singleChar) + singleChild.compressedPath
                return TrieNode(value: singleChild.value, isTerminal: singleChild.isTerminal, children: singleChild.children, compressedPath: newCompressedPath)
            }
        }
        return node
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
        
        if isTerminal {
            keys.append(fullPrefix)
        }
        
        children.forEach { char, node in
            let newPrefix = fullPrefix + String(char)
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
        let prefixString = String(prefix)
        
        if !compressedPath.isEmpty {
            if prefixString.hasPrefix(compressedPath) {
                let remainingPrefixCount = prefixString.count - compressedPath.count
                if remainingPrefixCount <= 0 {
                    return self
                }
                let newPrefix = Array(prefixString.dropFirst(compressedPath.count))
                return traverse(prefix: ArraySlice(newPrefix))
            } else if compressedPath.hasPrefix(prefixString) {
                return self
            } else {
                return TrieNode<Value>()
            }
        }
        
        guard let firstChar = prefix.first else {
            return self
        }
        
        guard let childNode = children.child(for: firstChar) else {
            return TrieNode<Value>()
        }
        
        let suffix = prefix.dropFirst()
        return childNode.traverse(prefix: suffix)
    }
}
