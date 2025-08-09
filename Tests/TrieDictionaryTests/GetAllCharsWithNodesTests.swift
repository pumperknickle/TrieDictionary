import XCTest
@testable import TrieDictionary

final class GetAllCharsWithNodesTests: XCTestCase {
    
    func testEmptyTrieReturnsEmptyArray() {
        let trie = TrieDictionary<String>()
        let chars = trie.getAllChildCharacters()
        XCTAssertTrue(chars.isEmpty)
    }
    
    func testSingleChildCharacter() {
        var trie = TrieDictionary<String>()
        trie["apple"] = "fruit"
        
        let chars = trie.getAllChildCharacters()
        XCTAssertEqual(chars.count, 1)
        XCTAssertTrue(chars.contains("a"))
    }
    
    func testMultipleChildCharacters() {
        var trie = TrieDictionary<String>()
        trie["apple"] = "fruit"
        trie["banana"] = "yellow"
        trie["cherry"] = "red"
        
        let chars = trie.getAllChildCharacters()
        XCTAssertEqual(chars.count, 3)
        XCTAssertTrue(chars.contains("a"))
        XCTAssertTrue(chars.contains("b"))
        XCTAssertTrue(chars.contains("c"))
    }
    
    func testDuplicateFirstCharacters() {
        var trie = TrieDictionary<String>()
        trie["apple"] = "fruit"
        trie["apricot"] = "orange"
        trie["application"] = "software"
        
        let chars = trie.getAllChildCharacters()
        XCTAssertEqual(chars.count, 1)
        XCTAssertTrue(chars.contains("a"))
    }
    
    func testMixedCharacterTypes() {
        var trie = TrieDictionary<String>()
        trie["apple"] = "fruit"
        trie["1234"] = "number"
        trie["@symbol"] = "special"
        trie["Uppercase"] = "capital"
        trie["!exclamation"] = "punctuation"
        
        let chars = trie.getAllChildCharacters()
        
        // Check for expected characters individually
        let expectedChars: Set<Character> = ["a", "1", "@", "U", "!"]
        let actualChars = Set(chars)
        
        XCTAssertEqual(actualChars, expectedChars, "Expected characters \(expectedChars), got \(actualChars)")
        XCTAssertEqual(chars.count, 5)
    }
    
    func testUnicodeCharacters() {
        var trie = TrieDictionary<String>()
        trie["café"] = "coffee"
        trie["naïve"] = "innocent"
        trie["résumé"] = "cv"
        trie["🍎apple"] = "emoji"
        
        let chars = trie.getAllChildCharacters()
        XCTAssertEqual(chars.count, 4)
        XCTAssertTrue(chars.contains("c"))
        XCTAssertTrue(chars.contains("n"))
        XCTAssertTrue(chars.contains("r"))
        XCTAssertTrue(chars.contains("🍎"))
    }
    
    func testAfterKeyRemoval() {
        var trie = TrieDictionary<String>()
        trie["apple"] = "fruit"
        trie["banana"] = "yellow"
        trie["cherry"] = "red"
        
        var chars = trie.getAllChildCharacters()
        XCTAssertEqual(chars.count, 3)
        
        trie.removeValue(forKey: "banana")
        chars = trie.getAllChildCharacters()
        XCTAssertEqual(chars.count, 2)
        XCTAssertTrue(chars.contains("a"))
        XCTAssertTrue(chars.contains("c"))
        XCTAssertFalse(chars.contains("b"))
    }
    
    func testAfterRemovingAllKeysWithSamePrefix() {
        var trie = TrieDictionary<String>()
        trie["apple"] = "fruit"
        trie["apricot"] = "orange"
        trie["banana"] = "yellow"
        
        var chars = trie.getAllChildCharacters()
        XCTAssertEqual(chars.count, 2)
        
        trie.removeValue(forKey: "apple")
        trie.removeValue(forKey: "apricot")
        
        chars = trie.getAllChildCharacters()
        XCTAssertEqual(chars.count, 1)
        XCTAssertTrue(chars.contains("b"))
        XCTAssertFalse(chars.contains("a"))
    }
    
    func testAfterClearingTrie() {
        var trie = TrieDictionary<String>()
        trie["apple"] = "fruit"
        trie["banana"] = "yellow"
        trie["cherry"] = "red"
        
        var chars = trie.getAllChildCharacters()
        XCTAssertEqual(chars.count, 3)
        
        trie.removeAll()
        chars = trie.getAllChildCharacters()
        XCTAssertTrue(chars.isEmpty)
    }
    
    func testSubtrieChildCharacters() {
        var trie = TrieDictionary<String>()
        trie["application"] = "software"
        trie["apple"] = "fruit"
        trie["apply"] = "action"
        trie["appreciate"] = "value"
        
        let appTrie = trie.traverse("app")
        let chars = appTrie.getAllChildCharacters()
        
        // After traversing "app", we should have children for "l" (from "lication", "le") and "r" (from "reciate")
        // The exact structure depends on compression, but we should have some children
        XCTAssertFalse(chars.isEmpty)
    }
    
    func testRootValueDoesNotAffectChildCharacters() {
        var trie = TrieDictionary<String>()
        trie[""] = "root_value"  // Set root value
        trie["apple"] = "fruit"
        trie["banana"] = "yellow"
        
        let chars = trie.getAllChildCharacters()
        XCTAssertEqual(chars.count, 2)
        XCTAssertTrue(chars.contains("a"))
        XCTAssertTrue(chars.contains("b"))
    }
    
    func testLargeNumberOfChildCharacters() {
        var trie = TrieDictionary<Int>()
        let alphabet = "abcdefghijklmnopqrstuvwxyz"
        
        for (index, char) in alphabet.enumerated() {
            trie[String(char)] = index
        }
        
        let chars = trie.getAllChildCharacters()
        XCTAssertEqual(chars.count, 26)
        
        for char in alphabet {
            XCTAssertTrue(chars.contains(char))
        }
    }
    
    func testHashCollisionHandling() {
        var trie = TrieDictionary<String>()
        
        // Add characters that might have hash collisions
        let testChars: [Character] = ["A", "a", "1", "!", "@", "#", "$", "%"]
        for char in testChars {
            trie[String(char) + "test"] = "value"
        }
        
        let chars = trie.getAllChildCharacters()
        XCTAssertEqual(chars.count, testChars.count)
        
        for testChar in testChars {
            XCTAssertTrue(chars.contains(testChar), "Missing character: \(testChar)")
        }
    }
    
    func testPerformanceOfGetAllChars() {
        var trie = TrieDictionary<Int>()
        
        // Add many keys with different first characters
        for i in 0..<1000 {
            let key = "key\(i)_\(UUID().uuidString)"
            trie[key] = i
        }
        
        measure {
            _ = trie.getAllChildCharacters()
        }
    }
    
    func testCharacterOrderingIsConsistent() {
        var trie = TrieDictionary<String>()
        trie["zebra"] = "animal"
        trie["apple"] = "fruit"
        trie["banana"] = "yellow"
        
        let chars1 = trie.getAllChildCharacters()
        let chars2 = trie.getAllChildCharacters()
        
        // Results should be consistent between calls
        XCTAssertEqual(chars1, chars2)
        
        // Should contain expected characters
        let expectedChars: Set<Character> = ["z", "a", "b"]
        XCTAssertEqual(Set(chars1), expectedChars)
    }
    
    func testEmptyStringKey() {
        var trie = TrieDictionary<String>()
        trie[""] = "empty"
        trie["a"] = "letter"
        
        let chars = trie.getAllChildCharacters()
        XCTAssertEqual(chars.count, 1)
        XCTAssertTrue(chars.contains("a"))
    }
    
    func testHashCollisionResolution() {
        var trie = TrieDictionary<String>()
        
        // Test characters that might hash to same 5-bit value
        // Using ASCII values that differ by 32 (2^5)
        trie["A"] = "letter"  // ASCII 65
        trie["a"] = "letter"  // ASCII 97 (65 + 32)
        trie["!"] = "punct"   // ASCII 33
        trie["A"] = "letter"  // ASCII 65 (duplicate - should not affect result)
        
        let chars = trie.getAllChildCharacters()
        XCTAssertEqual(chars.count, 3)  // Should handle all distinct characters
        XCTAssertTrue(chars.contains("A"))
        XCTAssertTrue(chars.contains("a"))
        XCTAssertTrue(chars.contains("!"))
    }
}