import XCTest
@testable import TrieDictionary

final class TraverseChildTests: XCTestCase {
    
    func testTraverseChildWithExistingChild() {
        var trie = TrieDictionary<String>()
        trie["apple"] = "fruit"
        trie["application"] = "software"
        trie["banana"] = "yellow"
        
        let childTrie = trie.traverseChild("a")
        XCTAssertNotNil(childTrie)
        XCTAssertEqual(childTrie?.count, 2)
    }
    
    func testTraverseChildWithNonExistentChild() {
        var trie = TrieDictionary<String>()
        trie["apple"] = "fruit"
        trie["banana"] = "yellow"
        
        let childTrie = trie.traverseChild("c")
        XCTAssertNil(childTrie)
    }
    
    func testTraverseChildEmptyTrie() {
        let trie = TrieDictionary<String>()
        
        let childTrie = trie.traverseChild("a")
        XCTAssertNil(childTrie)
    }
    
    func testTraverseChildSingleChild() {
        var trie = TrieDictionary<Int>()
        trie["hello"] = 42
        
        let childTrie = trie.traverseChild("h")
        XCTAssertNotNil(childTrie)
        XCTAssertEqual(childTrie?.count, 1)
    }
    
    func testTraverseChildPreservesRootValue() {
        var trie = TrieDictionary<String>()
        trie[""] = "root_value"
        trie["apple"] = "fruit"
        
        let childTrie = trie.traverseChild("a")
        XCTAssertNotNil(childTrie)
        XCTAssertEqual(childTrie?[""], "root_value")
    }
    
    func testTraverseChildMultipleCharacters() {
        var trie = TrieDictionary<String>()
        trie["apple"] = "fruit"
        trie["application"] = "software"
        trie["banana"] = "yellow"
        trie["ball"] = "round"
        trie["cat"] = "animal"
        
        let aTrie = trie.traverseChild("a")
        XCTAssertNotNil(aTrie)
        XCTAssertEqual(aTrie?.count, 2)
        
        let bTrie = trie.traverseChild("b")
        XCTAssertNotNil(bTrie)
        XCTAssertEqual(bTrie?.count, 2)
        
        let cTrie = trie.traverseChild("c")
        XCTAssertNotNil(cTrie)
        XCTAssertEqual(cTrie?.count, 1)
    }
    
    func testTraverseChildUnicodeCharacters() {
        var trie = TrieDictionary<String>()
        trie["café"] = "coffee"
        trie["car"] = "vehicle"
        trie["🚀rocket"] = "space"
        
        let cTrie = trie.traverseChild("c")
        XCTAssertNotNil(cTrie)
        XCTAssertEqual(cTrie?.count, 2)
        
        let rocketTrie = trie.traverseChild("🚀")
        XCTAssertNotNil(rocketTrie)
        XCTAssertEqual(rocketTrie?.count, 1)
    }
    
    func testTraverseChildReturnsNewInstance() {
        var trie = TrieDictionary<String>()
        trie["apple"] = "fruit"
        trie["application"] = "software"
        
        let childTrie1 = trie.traverseChild("a")
        let childTrie2 = trie.traverseChild("a")
        
        XCTAssertNotNil(childTrie1)
        XCTAssertNotNil(childTrie2)
        XCTAssertEqual(childTrie1?.count, childTrie2?.count)
    }
    
    func testTraverseChildAfterModification() {
        var trie = TrieDictionary<String>()
        trie["apple"] = "fruit"
        
        let childTrie1 = trie.traverseChild("a")
        XCTAssertEqual(childTrie1?.count, 1)
        
        trie["application"] = "software"
        
        let childTrie2 = trie.traverseChild("a")
        XCTAssertEqual(childTrie2?.count, 2)
        XCTAssertEqual(childTrie1?.count, 1) // Original should be unchanged
    }
    
    func testTraverseChildWithCompressedPaths() {
        var trie = TrieDictionary<String>()
        trie["application"] = "software"
        trie["appreciate"] = "thanks"
        
        let aTrie = trie.traverseChild("a")
        XCTAssertNotNil(aTrie)
        XCTAssertEqual(aTrie?.count, 2)
    }
}