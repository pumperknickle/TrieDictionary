import Foundation

internal struct CompressedChildArray<Value> {
    private let bitmap: UInt64
    private let nodes: [TrieNode<Value>]
    private let chars: [Character]
    
    init() {
        self.bitmap = 0
        self.nodes = []
        self.chars = []
    }
    
    private init(bitmap: UInt64, nodes: [TrieNode<Value>], chars: [Character]) {
        self.bitmap = bitmap
        self.nodes = nodes
        self.chars = chars
    }
    
    var isEmpty: Bool {
        bitmap == 0
    }
    
    var totalCount: Int {
        nodes.reduce(0) { $0 + $1.count }
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
            var newNodes = nodes
            var newChars = chars
            newNodes[index] = node
            newChars[index] = char
            return CompressedChildArray(bitmap: bitmap, nodes: newNodes, chars: newChars)
        } else {
            var newNodes = nodes
            var newChars = chars
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
        var newNodes = nodes
        var newChars = chars
        newNodes.remove(at: index)
        newChars.remove(at: index)
        let newBitmap = bitmap & ~bit
        
        return CompressedChildArray(bitmap: newBitmap, nodes: newNodes, chars: newChars)
    }
    
    func forEach(_ body: (Character, TrieNode<Value>) -> Void) {
        for i in 0..<nodes.count {
            body(chars[i], nodes[i])
        }
    }
    
    private func hashCharacter(_ char: Character) -> Int {
        let scalar = char.unicodeScalars.first?.value ?? 0
        return Int(scalar % 64)
    }
    
    private func popCount(_ value: UInt64) -> Int {
        return value.nonzeroBitCount
    }
}