import XCTest
@testable import TrieDictionary

final class TraverseToNextChildTests: XCTestCase {
    
    func testTraverseToNextChildWithExistingChar() {
        var trie = TrieDictionary<String>()
        trie["apple"] = "fruit"
        trie["application"] = "software"
        trie["banana"] = "yellow"
        
        let result = trie.traverseToNextChild("a")
        XCTAssertNotNil(result)
        let (nodePath, childTrie) = result!
        
        // Should return the compressed path for the child starting with 'a'
        XCTAssertEqual(nodePath, "appl")
        
        // The child trie should contain the diverging suffixes
        XCTAssertEqual(childTrie.count, 2)
        XCTAssertEqual(childTrie["e"], "fruit")
        XCTAssertEqual(childTrie["ication"], "software")
    }
    
    func testTraverseToNextChildWithNonExistentChar() {
        var trie = TrieDictionary<String>()
        trie["apple"] = "fruit"
        trie["banana"] = "yellow"
        
        let result = trie.traverseToNextChild("c")
        XCTAssertNil(result)
    }
    
    func testTraverseToNextChildEmptyTrie() {
        let trie = TrieDictionary<String>()
        
        let result = trie.traverseToNextChild("a")
        XCTAssertNil(result)
    }
    
    func testTraverseToNextChildWithValidChar() {
        var trie = TrieDictionary<String>()
        trie["apple"] = "fruit"
        
        let result = trie.traverseToNextChild("a")
        XCTAssertNotNil(result)
        let (path, childTrie) = result!
        // For a single entry, the entire key becomes the compressed path  
        XCTAssertEqual(path, "apple")
        XCTAssertEqual(childTrie[""], "fruit")
        XCTAssertEqual(childTrie.count, 1)
    }
    
    func testTraverseToNextChildSingleCharacter() {
        var trie = TrieDictionary<String>()
        trie["a"] = "letter_a"
        trie["apple"] = "fruit"
        
        let result = trie.traverseToNextChild("a")
        XCTAssertNotNil(result)
        let (path, childTrie) = result!
        // Should return the common prefix for entries starting with 'a'
        XCTAssertEqual(path, "a")
        XCTAssertEqual(childTrie.count, 2)
        XCTAssertEqual(childTrie[""], "letter_a") // Value at the common prefix
        XCTAssertEqual(childTrie["pple"], "fruit") // Remaining suffix
    }
    
    func testTraverseToNextChildMultipleChildren() {
        var trie = TrieDictionary<String>()
        trie["apple"] = "fruit"
        trie["application"] = "software"
        trie["banana"] = "yellow"
        trie["ball"] = "round"
        
        let resultA = trie.traverseToNextChild("a")
        XCTAssertNotNil(resultA)
        let (pathA, childTrieA) = resultA!
        // Should return the common prefix for words starting with 'a'
        XCTAssertEqual(pathA, "appl")
        XCTAssertEqual(childTrieA.count, 2)
        
        let resultB = trie.traverseToNextChild("b")
        XCTAssertNotNil(resultB)
        let (pathB, childTrieB) = resultB!
        // Should return the common prefix for words starting with 'b'
        XCTAssertEqual(pathB, "ba")
        XCTAssertEqual(childTrieB.count, 2)
    }
    
    func testTraverseToNextChildCompressedPath() {
        var trie = TrieDictionary<String>()
        trie["application"] = "software"
        trie["appreciate"] = "thanks"
        
        let result = trie.traverseToNextChild("a")
        XCTAssertNotNil(result)
        let (path, childTrie) = result!
        
        // Should return the common prefix "app"
        XCTAssertEqual(path, "app")
        XCTAssertEqual(childTrie.count, 2)
        XCTAssertEqual(childTrie["lication"], "software")
        XCTAssertEqual(childTrie["reciate"], "thanks")
    }
    
    func testTraverseToNextChildReturnsFirstChild() {
        var trie = TrieDictionary<String>()
        trie["apple"] = "fruit"
        trie["application"] = "software"
        
        let result = trie.traverseToNextChild("a")
        XCTAssertNotNil(result)
        let (path, childTrie) = result!
        // Should return the common prefix and the diverging suffixes
        XCTAssertEqual(path, "appl")
        XCTAssertEqual(childTrie.count, 2)
        XCTAssertEqual(childTrie["e"], "fruit")
        XCTAssertEqual(childTrie["ication"], "software")
    }
    
    func testTraverseToNextChildUnicodeCharacters() {
        var trie = TrieDictionary<String>()
        trie["café"] = "coffee"
        trie["🚀rocket"] = "space"
        
        let resultCafe = trie.traverseToNextChild("c")
        XCTAssertNotNil(resultCafe)
        let (pathCafe, childCafe) = resultCafe!
        XCTAssertEqual(pathCafe, "café")
        XCTAssertEqual(childCafe[""], "coffee")
        
        let resultRocket = trie.traverseToNextChild("🚀")
        XCTAssertNotNil(resultRocket)
        let (pathRocket, childRocket) = resultRocket!
        XCTAssertEqual(pathRocket, "🚀rocket")
        XCTAssertEqual(childRocket[""], "space")
    }
    
    func testTraverseToNextChildReturnsCorrectSubtrie() {
        var trie = TrieDictionary<String>()
        trie["apple"] = "fruit"
        trie["application"] = "software"
        trie["apply"] = "action"
        
        let result = trie.traverseToNextChild("a")
        XCTAssertNotNil(result)
        let (nodePath, childTrie) = result!
        
        // Should return the common prefix and the diverging suffixes
        XCTAssertEqual(nodePath, "appl")
        XCTAssertEqual(childTrie.count, 3)
        XCTAssertEqual(childTrie["e"], "fruit")
        XCTAssertEqual(childTrie["ication"], "software")
        XCTAssertEqual(childTrie["y"], "action")
    }
    
    func testTraverseToNextChildWithRootValue() {
        var trie = TrieDictionary<String>()
        trie[""] = "root"
        trie["apple"] = "fruit"
        
        let result = trie.traverseToNextChild("a")
        XCTAssertNotNil(result)
        let (path, childTrie) = result!
        XCTAssertEqual(path, "apple")
        XCTAssertEqual(childTrie[""], "fruit")
    }
    
    func testTraverseToNextChildShortKey() {
        var trie = TrieDictionary<String>()
        trie["app"] = "application"
        
        let result = trie.traverseToNextChild("a")
        XCTAssertNotNil(result)
        let (path, childTrie) = result!
        XCTAssertEqual(path, "app")
        XCTAssertEqual(childTrie[""], "application")
    }
    
    func testTraverseToNextChildMismatchedChar() {
        var trie = TrieDictionary<String>()
        trie["apple"] = "fruit"
        trie["banana"] = "yellow"
        
        let result = trie.traverseToNextChild("g")
        XCTAssertNil(result)
    }
    
    func testTraverseToNextChildAfterModification() {
        var trie = TrieDictionary<String>()
        trie["apple"] = "fruit"
        
        let result1 = trie.traverseToNextChild("a")
        XCTAssertNotNil(result1)
        
        trie["apple"] = "red_fruit"
        
        let result2 = trie.traverseToNextChild("a")
        XCTAssertNotNil(result2)
        let (_, childTrie2) = result2!
        XCTAssertEqual(childTrie2[""], "red_fruit")
        
        // Original result should be unaffected due to value type semantics
        let (_, childTrie1) = result1!
        XCTAssertEqual(childTrie1[""], "fruit")
    }
}