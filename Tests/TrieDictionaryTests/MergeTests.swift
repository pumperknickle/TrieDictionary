import XCTest
@testable import TrieDictionary

final class MergeTests: XCTestCase {
    
    func testMergeEmptyTries() {
        let trie1 = TrieDictionary<Int>()
        let trie2 = TrieDictionary<Int>()
        
        let merged = trie1.merge(other: trie2) { a, b in a + b }
        
        XCTAssertTrue(merged.isEmpty)
        XCTAssertEqual(merged.count, 0)
    }
    
    func testMergeWithEmptyTrie() {
        var trie1 = TrieDictionary<String>()
        trie1["apple"] = "red"
        trie1["banana"] = "yellow"
        
        let trie2 = TrieDictionary<String>()
        
        let merged = trie1.merge(other: trie2) { a, b in a + "/" + b }
        
        XCTAssertEqual(merged.count, 2)
        XCTAssertEqual(merged["apple"], "red")
        XCTAssertEqual(merged["banana"], "yellow")
    }
    
    func testMergeEmptyWithNonEmpty() {
        let trie1 = TrieDictionary<String>()
        
        var trie2 = TrieDictionary<String>()
        trie2["cherry"] = "red"
        trie2["grape"] = "purple"
        
        let merged = trie1.merge(other: trie2) { a, b in a + "/" + b }
        
        XCTAssertEqual(merged.count, 2)
        XCTAssertEqual(merged["cherry"], "red")
        XCTAssertEqual(merged["grape"], "purple")
    }
    
    func testMergeDisjointKeys() {
        var trie1 = TrieDictionary<Int>()
        trie1["apple"] = 1
        trie1["banana"] = 2
        
        var trie2 = TrieDictionary<Int>()
        trie2["cherry"] = 3
        trie2["date"] = 4
        
        let merged = trie1.merge(other: trie2) { a, b in a + b }
        
        XCTAssertEqual(merged.count, 4)
        XCTAssertEqual(merged["apple"], 1)
        XCTAssertEqual(merged["banana"], 2)
        XCTAssertEqual(merged["cherry"], 3)
        XCTAssertEqual(merged["date"], 4)
    }
    
    func testMergeOverlappingKeys() {
        var trie1 = TrieDictionary<Int>()
        trie1["apple"] = 1
        trie1["banana"] = 2
        trie1["cherry"] = 3
        
        var trie2 = TrieDictionary<Int>()
        trie2["apple"] = 10
        trie2["banana"] = 20
        trie2["date"] = 4
        
        let merged = trie1.merge(other: trie2) { a, b in a + b }
        
        XCTAssertEqual(merged.count, 4)
        XCTAssertEqual(merged["apple"], 11)
        XCTAssertEqual(merged["banana"], 22)
        XCTAssertEqual(merged["cherry"], 3)
        XCTAssertEqual(merged["date"], 4)
    }
    
    func testMergeWithCommonPrefixes() {
        var trie1 = TrieDictionary<String>()
        trie1["app"] = "application"
        trie1["apple"] = "fruit"
        trie1["apply"] = "action"
        
        var trie2 = TrieDictionary<String>()
        trie2["app"] = "program"
        trie2["application"] = "software"
        trie2["approximate"] = "rough"
        
        let merged = trie1.merge(other: trie2) { a, b in "\(a)|\(b)" }
        
        XCTAssertEqual(merged.count, 5)
        XCTAssertEqual(merged["app"], "application|program")
        XCTAssertEqual(merged["apple"], "fruit")
        XCTAssertEqual(merged["apply"], "action")
        XCTAssertEqual(merged["application"], "software")
        XCTAssertEqual(merged["approximate"], "rough")
    }
    
    func testMergeCompressedPaths() {
        var trie1 = TrieDictionary<Int>()
        trie1["uncompressed"] = 1
        
        var trie2 = TrieDictionary<Int>()
        trie2["uncommon"] = 2
        trie2["uncompressed"] = 10
        
        let merged = trie1.merge(other: trie2) { a, b in a * b }
        
        XCTAssertEqual(merged.count, 2)
        XCTAssertEqual(merged["uncompressed"], 10) // 1 * 10
        XCTAssertEqual(merged["uncommon"], 2)
        XCTAssertTrue(merged.isFullyCompressed)
    }
    
    func testMergeRootValues() {
        var trie1 = TrieDictionary<String>()
        trie1[""] = "root1"
        trie1["child"] = "child1"
        
        var trie2 = TrieDictionary<String>()
        trie2[""] = "root2"
        trie2["other"] = "other"
        
        let merged = trie1.merge(other: trie2) { a, b in "\(a)+\(b)" }
        
        XCTAssertEqual(merged.count, 3)
        XCTAssertEqual(merged[""], "root1+root2")
        XCTAssertEqual(merged["child"], "child1")
        XCTAssertEqual(merged["other"], "other")
    }
    
    func testMergePreservesCompression() {
        var trie1 = TrieDictionary<Int>()
        trie1["verylongkey"] = 1
        
        var trie2 = TrieDictionary<Int>()
        trie2["verylongkeyword"] = 2
        
        let merged = trie1.merge(other: trie2) { a, b in a + b }
        
        XCTAssertEqual(merged.count, 2)
        XCTAssertEqual(merged["verylongkey"], 1)
        XCTAssertEqual(merged["verylongkeyword"], 2)
        XCTAssertTrue(merged.isFullyCompressed)
    }
    
    func testMergeComplexStructure() {
        // Build two complex tries with overlapping structure
        var trie1 = TrieDictionary<Int>()
        trie1[""] = 0
        trie1["a"] = 1
        trie1["ab"] = 2
        trie1["abc"] = 3
        trie1["abd"] = 4
        trie1["ac"] = 5
        trie1["b"] = 6
        
        var trie2 = TrieDictionary<Int>()
        trie2[""] = 100
        trie2["a"] = 110
        trie2["ab"] = 120
        trie2["abe"] = 140
        trie2["ac"] = 150
        trie2["c"] = 160
        
        let merged = trie1.merge(other: trie2) { a, b in a + b }
        
        XCTAssertEqual(merged.count, 9)
        XCTAssertEqual(merged[""], 100)      // 0 + 100
        XCTAssertEqual(merged["a"], 111)     // 1 + 110
        XCTAssertEqual(merged["ab"], 122)    // 2 + 120
        XCTAssertEqual(merged["abc"], 3)     // only in trie1
        XCTAssertEqual(merged["abd"], 4)     // only in trie1
        XCTAssertEqual(merged["abe"], 140)   // only in trie2
        XCTAssertEqual(merged["ac"], 155)    // 5 + 150
        XCTAssertEqual(merged["b"], 6)       // only in trie1
        XCTAssertEqual(merged["c"], 160)     // only in trie2
        
        XCTAssertTrue(merged.isFullyCompressed)
    }
    
    func testMergeDifferentMergeRules() {
        var trie1 = TrieDictionary<Int>()
        trie1["key1"] = 5
        trie1["key2"] = 10
        
        var trie2 = TrieDictionary<Int>()
        trie2["key1"] = 3
        trie2["key3"] = 7
        
        // Test max merge rule
        let maxMerged = trie1.merge(other: trie2) { a, b in max(a, b) }
        XCTAssertEqual(maxMerged["key1"], 5)
        XCTAssertEqual(maxMerged["key2"], 10)
        XCTAssertEqual(maxMerged["key3"], 7)
        
        // Test min merge rule
        let minMerged = trie1.merge(other: trie2) { a, b in min(a, b) }
        XCTAssertEqual(minMerged["key1"], 3)
        XCTAssertEqual(minMerged["key2"], 10)
        XCTAssertEqual(minMerged["key3"], 7)
    }
    
    func testMergeKeysWithValues() {
        var trie1 = TrieDictionary<String>()
        trie1["apple"] = "red"
        trie1["app"] = "application"
        
        var trie2 = TrieDictionary<String>()
        trie2["apple"] = "green"
        trie2["application"] = "software"
        
        let merged = trie1.merge(other: trie2) { a, b in "\(a)_\(b)" }
        
        XCTAssertEqual(merged.count, 3)
        XCTAssertEqual(merged["apple"], "red_green")
        XCTAssertEqual(merged["app"], "application")
        XCTAssertEqual(merged["application"], "software")
    }
    
    func testMergeResultIndependence() {
        var trie1 = TrieDictionary<Int>()
        trie1["key"] = 1
        
        var trie2 = TrieDictionary<Int>()
        trie2["key"] = 2
        
        let merged = trie1.merge(other: trie2) { a, b in a + b }
        
        // Modify original tries
        trie1["key"] = 100
        trie2["key"] = 200
        
        // Merged result should be unchanged
        XCTAssertEqual(merged["key"], 3)
        XCTAssertEqual(trie1["key"], 100)
        XCTAssertEqual(trie2["key"], 200)
    }
}
