import Foundation

internal struct CompressedChildArray<Value> {
    private let bitmap: UInt64
    private let nodes: ContiguousArray<TrieNode<Value>>
    private let chars: ContiguousArray<Character>
    
    init() {
        self.bitmap = 0
        self.nodes = []
        self.chars = []
    }
    
    private init(bitmap: UInt64, nodes: ContiguousArray<TrieNode<Value>>, chars: ContiguousArray<Character>) {
        self.bitmap = bitmap
        self.nodes = nodes
        self.chars = chars
    }
    
    @inline(__always)
    var isEmpty: Bool {
        bitmap == 0
    }
    
    var totalCount: Int {
        var count = 0
        let nodeCount = nodes.count
        for i in 0..<nodeCount {
            count += nodes[i].count
        }
        return count
    }
    
    func child(for char: Character) -> TrieNode<Value>? {
        let hash = hashCharacter(char)
        let bit = UInt64(1) << hash
        
        guard (bitmap & bit) != 0 else {
            return nil
        }
        
        let index = popCount(bitmap & (bit - 1))
        return nodes[index]
    }
    
    func setting(char: Character, node: TrieNode<Value>) -> CompressedChildArray<Value> {
        let hash = hashCharacter(char)
        let bit = UInt64(1) << hash
        let index = popCount(bitmap & (bit - 1))
        
        if (bitmap & bit) != 0 {
            // Update existing entry
            var newNodes = ContiguousArray(nodes)
            var newChars = ContiguousArray(chars)
            newNodes[index] = node
            newChars[index] = char
            return CompressedChildArray(bitmap: bitmap, nodes: newNodes, chars: newChars)
        } else {
            // Optimize: Pre-allocate arrays with known capacity
            var newNodes = ContiguousArray(nodes)
            var newChars = ContiguousArray(chars)
            newNodes.reserveCapacity(nodes.count + 1)
            newChars.reserveCapacity(chars.count + 1)
            newNodes.insert(node, at: index)
            newChars.insert(char, at: index)
            let newBitmap = bitmap | bit
            return CompressedChildArray(bitmap: newBitmap, nodes: newNodes, chars: newChars)
        }
    }
    
    func removing(char: Character) -> CompressedChildArray<Value> {
        let hash = hashCharacter(char)
        let bit = UInt64(1) << hash
        
        guard (bitmap & bit) != 0 else {
            return self
        }
        
        let index = popCount(bitmap & (bit - 1))
        var newNodes = ContiguousArray(nodes)
        var newChars = ContiguousArray(chars)
        newNodes.remove(at: index)
        newChars.remove(at: index)
        let newBitmap = bitmap & ~bit
        
        return CompressedChildArray(bitmap: newBitmap, nodes: newNodes, chars: newChars)
    }
    
    @inline(__always)
    func forEach(_ body: (TrieNode<Value>) -> Void) {
        let count = nodes.count
        for i in 0..<count {
            body(nodes[i])
        }
    }
    
    var firstChild: TrieNode<Value>? {
        guard !nodes.isEmpty else { return nil }
        return nodes[0]
    }
    
    @inline(__always)
    var childCount: Int {
        nodes.count
    }
    
    @inline(__always)
    private func hashCharacter(_ char: Character) -> Int {
        let scalar = char.unicodeScalars.first?.value ?? 0
        return Int(scalar & 63) // Use bit masking instead of modulo
    }
    
    @inline(__always)
    private func popCount(_ value: UInt64) -> Int {
        return value.nonzeroBitCount
    }
}
