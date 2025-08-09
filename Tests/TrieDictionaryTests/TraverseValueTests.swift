import XCTest
@testable import TrieDictionary

final class TraverseValueTests: XCTestCase {
    
    func testTraversePreservesValueAtDestination() {
        var trie = TrieDictionary<String>()
        
        // Set up test data
        trie["app"] = "application"
        trie["apple"] = "fruit"
        trie["application"] = "software"
        trie["apply"] = "action"
        
        // Test traversing to "app" - should set "application" as root value in the new trie
        let traversedTrie = trie.traverse("app")
        
        // The root value should be "application" (the value at the "app" key)
        XCTAssertEqual(traversedTrie[""], "application", "Root value should be the value at the traversal destination")
        
        // Check that other values are still accessible with their suffixes
        XCTAssertEqual(traversedTrie["le"], "fruit", "Should find 'fruit' at 'le' (suffix of 'apple')")
        XCTAssertEqual(traversedTrie["lication"], "software", "Should find 'software' at 'lication' (suffix of 'application')")
        XCTAssertEqual(traversedTrie["ly"], "action", "Should find 'action' at 'ly' (suffix of 'apply')")
    }
    
    func testTraverseWithNoValueAtDestination() {
        var trie = TrieDictionary<String>()
        
        // Set up test data where prefix has no value
        trie["prefix_apple"] = "fruit"
        trie["prefix_tree"] = "plant"
        
        // Test traversing to a prefix that doesn't have a value
        let prefixTrie = trie.traverse("prefix_")
        
        // The root value should be nil since "prefix_" has no value
        XCTAssertNil(prefixTrie[""], "Root value should be nil when no value exists at traversal destination")
        
        // Check that other values are still accessible
        XCTAssertEqual(prefixTrie["apple"], "fruit", "Should find 'fruit' at 'apple'")
        XCTAssertEqual(prefixTrie["tree"], "plant", "Should find 'plant' at 'tree'")
    }
    
    func testTraverseEmptyPrefix() {
        var trie = TrieDictionary<String>()
        trie[""] = "root"
        trie["apple"] = "fruit"
        
        // Traversing with empty prefix should return the same trie
        let traversedTrie = trie.traverse("")
        
        XCTAssertEqual(traversedTrie[""], "root")
        XCTAssertEqual(traversedTrie["apple"], "fruit")
    }
    
    func testTraverseNonExistentPrefix() {
        var trie = TrieDictionary<String>()
        trie["apple"] = "fruit"
        
        // Traversing to a non-existent prefix should return empty trie
        let traversedTrie = trie.traverse("banana")
        
        XCTAssertTrue(traversedTrie.isEmpty, "Traversing non-existent prefix should return empty trie")
    }
}