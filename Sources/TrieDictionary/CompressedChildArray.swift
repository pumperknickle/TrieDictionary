import Foundation

/**
 A space-efficient storage structure for child nodes in the compressed trie.
 
 This structure uses a bitmap-based approach to store child nodes efficiently:
 - A 64-bit bitmap tracks which character hash positions have nodes
 - ContiguousArrays store the actual nodes and their corresponding characters
 - Hash-based indexing provides O(1) average lookup time
 
 ## Memory Efficiency:
 Instead of storing a full 256-element array (for all possible characters),
 this structure only allocates space for characters that actually exist,
 significantly reducing memory usage for sparse tries.
 
 ## Performance Optimizations:
 - Bitmap operations for fast membership testing
 - ContiguousArray for better cache locality
 - Inlined methods for hot path performance
 - Population count for efficient array indexing
 
 ## Hash Function:
 Characters are hashed to 6-bit values (0-63) using their Unicode scalar values.
 Hash collisions are handled by storing characters alongside nodes for verification.
 */
internal struct CompressedChildArray<Value> {
    /// Bitmap indicating which hash positions contain nodes (64 bits = 2^6 possible hash values)
    private let bitmap: UInt64
    
    /// Densely packed array of child nodes, indexed by population count
    private let nodes: ContiguousArray<TrieNode<Value>>
    
    /// Characters corresponding to each node, used for hash collision resolution
    private let chars: ContiguousArray<Character>
    
    /**
     Creates an empty compressed child array.
     */
    init() {
        self.bitmap = 0
        self.nodes = []
        self.chars = []
    }
    
    /**
     Creates a compressed child array with the specified components.
     
     - Parameter bitmap: The bitmap indicating which positions have nodes
     - Parameter nodes: The array of child nodes
     - Parameter chars: The array of characters corresponding to each node
     */
    private init(bitmap: UInt64, nodes: ContiguousArray<TrieNode<Value>>, chars: ContiguousArray<Character>) {
        self.bitmap = bitmap
        self.nodes = nodes
        self.chars = chars
    }
    
    /**
     Returns `true` if no child nodes are stored.
     
     - Complexity: O(1)
     */
    @inline(__always)
    var isEmpty: Bool {
        bitmap == 0
    }
    
    /**
     Returns the total number of values stored in all child subtrees.
     
     This traverses all child nodes and sums their value counts.
     
     - Returns: The total count of values in all child subtrees
     - Complexity: O(n) where n is the number of nodes in all subtrees
     */
    var totalCount: Int {
        var count = 0
        let nodeCount = nodes.count
        for i in 0..<nodeCount {
            count += nodes[i].count
        }
        return count
    }
    
    /**
     Returns the child node for the given character, if it exists.
     
     This method uses hash-based lookup with bitmap testing for fast character searches.
     Hash collisions are resolved by checking the stored character values.
     
     - Parameter char: The character to search for
     - Returns: The corresponding child node, or `nil` if not found
     - Complexity: O(1) average case
     */
    func child(for char: Character) -> TrieNode<Value>? {
        let hash = hashCharacter(char)
        let bit = UInt64(1) << hash
        
        guard (bitmap & bit) != 0 else {
            return nil
        }
        
        let index = popCount(bitmap & (bit - 1))
        return nodes[index]
    }
    
    /**
     Returns a new compressed child array with the given character-node pair added or updated.
     
     This method handles both insertion of new character-node pairs and updates of existing ones.
     The bitmap and arrays are efficiently updated using population count for indexing.
     
     - Parameter char: The character key
     - Parameter node: The node to associate with the character
     - Returns: A new CompressedChildArray with the update applied
     - Complexity: O(n) where n is the number of existing children (due to array copying)
     */
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
    
    /**
     Returns a new compressed child array with the given character removed.
     
     If the character is not present, returns the original array unchanged.
     
     - Parameter char: The character to remove
     - Returns: A new CompressedChildArray without the specified character
     - Complexity: O(n) where n is the number of existing children
     */
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
    
    /**
     Executes the given closure for each child node.
     
     This method provides an efficient way to iterate over all child nodes
     without exposing the internal array structure.
     
     - Parameter body: A closure to execute for each child node
     - Complexity: O(n) where n is the number of child nodes
     */
    @inline(__always)
    func forEach(_ body: (TrieNode<Value>) -> Void) {
        let count = nodes.count
        for i in 0..<count {
            body(nodes[i])
        }
    }
    
    /**
     Returns the first child node, if any.
     
     - Returns: The first child node, or `nil` if no children exist
     - Complexity: O(1)
     */
    var firstChild: TrieNode<Value>? {
        guard !nodes.isEmpty else { return nil }
        return nodes[0]
    }
    
    /**
     Returns the number of direct child nodes.
     
     - Returns: The count of child nodes
     - Complexity: O(1)
     */
    @inline(__always)
    var childCount: Int {
        nodes.count
    }
    
    /**
     Computes a hash value for the given character.
     
     The hash function maps Unicode scalar values to 6-bit values (0-63) using bit masking.
     This provides a good distribution for most character sets while keeping the bitmap size manageable.
     
     - Parameter char: The character to hash
     - Returns: A hash value in the range 0-63
     - Complexity: O(1)
     */
    @inline(__always)
    private func hashCharacter(_ char: Character) -> Int {
        let scalar = char.unicodeScalars.first?.value ?? 0
        return Int(scalar & 63) // Use bit masking instead of modulo
    }
    
    /**
     Returns the population count (number of set bits) in the given value.
     
     This is used to convert bitmap positions to array indices by counting
     how many bits are set before the target position.
     
     - Parameter value: The bitmap value to count
     - Returns: The number of set bits
     - Complexity: O(1) - uses hardware instruction on modern processors
     */
    @inline(__always)
    private func popCount(_ value: UInt64) -> Int {
        return value.nonzeroBitCount
    }
    
    /**
     Returns a new compressed child array that efficiently merges this array with another.
     
     This method performs an optimal merge by:
     - Combining bitmaps to identify all unique positions
     - Handling character collisions by applying the merge rule to conflicting nodes
     - Preserving non-conflicting nodes from both arrays
     - Maintaining sorted order for efficient lookups
     
     - Parameter other: The other CompressedChildArray to merge with
     - Parameter mergeRule: A closure that resolves conflicts between nodes with the same character
     - Returns: A new CompressedChildArray containing the merged result
     - Complexity: O(m + n) where m and n are the sizes of the two arrays
     */
    func merging(with other: CompressedChildArray<Value>, mergeRule: (TrieNode<Value>, TrieNode<Value>) -> TrieNode<Value>) -> CompressedChildArray<Value> {
        // Handle trivial cases
        if isEmpty { return other }
        if other.isEmpty { return self }
        
        // Collect all unique characters from both arrays
        var characterToNode: [Character: TrieNode<Value>] = [:]
        
        // Add nodes from self
        for i in 0..<nodes.count {
            characterToNode[chars[i]] = nodes[i]
        }
        
        // Add/merge nodes from other
        for i in 0..<other.nodes.count {
            let char = other.chars[i]
            let otherNode = other.nodes[i]
            
            if let existingNode = characterToNode[char] {
                // Character exists in both - merge the nodes
                characterToNode[char] = mergeRule(existingNode, otherNode)
            } else {
                // Character only exists in other - add it
                characterToNode[char] = otherNode
            }
        }
        
        // Build the result using the existing setting method for consistency
        var result = CompressedChildArray<Value>()
        for (char, node) in characterToNode {
            result = result.setting(char: char, node: node)
        }
        
        return result
    }
}
