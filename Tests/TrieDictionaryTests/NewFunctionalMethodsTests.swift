import XCTest
@testable import TrieDictionary

class NewFunctionalMethodsTests: XCTestCase {
    
    // MARK: - Key Filtering Tests
    
    func testFilteringKeys() {
        let dict: TrieDictionary<Int> = ["apple": 1, "application": 2, "banana": 3, "band": 4]
        
        let appleKeys = dict.filteringKeys { $0.hasPrefix("app") }
        XCTAssertEqual(appleKeys.count, 2)
        XCTAssertEqual(appleKeys["apple"], 1)
        XCTAssertEqual(appleKeys["application"], 2)
        XCTAssertNil(appleKeys["banana"])
    }
    
    func testFilteringValues() {
        let dict: TrieDictionary<Int> = ["a": 1, "b": 2, "c": 3, "d": 4]
        
        let evenValues = dict.filteringValues { $0 % 2 == 0 }
        XCTAssertEqual(evenValues.count, 2)
        XCTAssertEqual(evenValues["b"], 2)
        XCTAssertEqual(evenValues["d"], 4)
        XCTAssertNil(evenValues["a"])
        XCTAssertNil(evenValues["c"])
    }
    
    func testMapKeys() {
        let dict: TrieDictionary<String> = ["a": "alpha", "b": "beta"]
        
        let uppercased = dict.mapKeys { $0.uppercased() }
        XCTAssertEqual(uppercased.count, 2)
        XCTAssertEqual(uppercased["A"], "alpha")
        XCTAssertEqual(uppercased["B"], "beta")
        XCTAssertNil(uppercased["a"])
    }
    
    // MARK: - Prefix/Suffix Tests
    
    func testWithPrefix() {
        let dict: TrieDictionary<Int> = ["apple": 1, "application": 2, "banana": 3, "apply": 4]
        
        let appPrefixed = dict.withPrefix("app")
        XCTAssertEqual(appPrefixed.count, 3)
        XCTAssertEqual(appPrefixed["apple"], 1)
        XCTAssertEqual(appPrefixed["application"], 2)
        XCTAssertEqual(appPrefixed["apply"], 4)
        XCTAssertNil(appPrefixed["banana"])
    }
    
    func testWithSuffix() {
        let dict: TrieDictionary<String> = ["testing": "test", "running": "run", "swimming": "swim", "test": "t"]
        
        let ingSuffixed = dict.withSuffix("ing")
        XCTAssertEqual(ingSuffixed.count, 3)
        XCTAssertEqual(ingSuffixed["testing"], "test")
        XCTAssertEqual(ingSuffixed["running"], "run")
        XCTAssertEqual(ingSuffixed["swimming"], "swim")
        XCTAssertNil(ingSuffixed["test"])
    }
    
    func testMatching() {
        let dict: TrieDictionary<Int> = ["a": 1, "aa": 2, "aaa": 3, "b": 4]
        
        let singleChar = dict.matching { $0.count == 1 }
        XCTAssertEqual(singleChar.count, 2)
        XCTAssertEqual(singleChar["a"], 1)
        XCTAssertEqual(singleChar["b"], 4)
        XCTAssertNil(singleChar["aa"])
    }
    
    // MARK: - Partitioning Tests
    
    func testPartitioned() {
        let dict: TrieDictionary<Int> = ["a": 1, "b": 2, "c": 3, "d": 4]
        
        let (evens, odds) = dict.partitioned { $0.value % 2 == 0 }
        
        XCTAssertEqual(evens.count, 2)
        XCTAssertEqual(evens["b"], 2)
        XCTAssertEqual(evens["d"], 4)
        
        XCTAssertEqual(odds.count, 2)
        XCTAssertEqual(odds["a"], 1)
        XCTAssertEqual(odds["c"], 3)
    }
    
    // MARK: - Value Replacement Tests
    
    func testReplacingValues() {
        let dict: TrieDictionary<String> = ["hello": "world", "foo": "bar"]
        
        let lengths = dict.replacingValues { key, value in key.count + value.count }
        XCTAssertEqual(lengths["hello"], 10) // "hello".count + "world".count = 5 + 5
        XCTAssertEqual(lengths["foo"], 6)    // "foo".count + "bar".count = 3 + 3
    }
    
    // MARK: - Key Length Filtering Tests
    
    func testFilteringKeyLength() {
        let dict: TrieDictionary<Int> = ["a": 1, "ab": 2, "abc": 3, "abcd": 4]
        
        let longKeys = dict.filteringKeyLength { $0 >= 3 }
        XCTAssertEqual(longKeys.count, 2)
        XCTAssertEqual(longKeys["abc"], 3)
        XCTAssertEqual(longKeys["abcd"], 4)
        XCTAssertNil(longKeys["a"])
        XCTAssertNil(longKeys["ab"])
    }
    
    func testWithMinKeyLength() {
        let dict: TrieDictionary<String> = ["a": "1", "ab": "2", "abc": "3"]
        
        let minTwo = dict.withMinKeyLength(2)
        XCTAssertEqual(minTwo.count, 2)
        XCTAssertEqual(minTwo["ab"], "2")
        XCTAssertEqual(minTwo["abc"], "3")
        XCTAssertNil(minTwo["a"])
    }
    
    func testWithMaxKeyLength() {
        let dict: TrieDictionary<String> = ["a": "1", "ab": "2", "abc": "3"]
        
        let maxTwo = dict.withMaxKeyLength(2)
        XCTAssertEqual(maxTwo.count, 2)
        XCTAssertEqual(maxTwo["a"], "1")
        XCTAssertEqual(maxTwo["ab"], "2")
        XCTAssertNil(maxTwo["abc"])
    }
    
    func testWithKeyLength() {
        let dict: TrieDictionary<Int> = ["a": 1, "ab": 2, "abc": 3, "abcd": 4]
        
        let exactThree = dict.withKeyLength(3)
        XCTAssertEqual(exactThree.count, 1)
        XCTAssertEqual(exactThree["abc"], 3)
        XCTAssertNil(exactThree["a"])
        XCTAssertNil(exactThree["ab"])
        XCTAssertNil(exactThree["abcd"])
    }
    
    // MARK: - Unique Values Tests
    
    func testUniqueValues() {
        let dict: TrieDictionary<String> = ["a": "duplicate", "b": "unique", "c": "duplicate", "d": "another"]
        
        let unique = dict.uniqueValues()
        XCTAssertEqual(unique.count, 3)
        XCTAssertTrue(unique.values().contains("duplicate"))
        XCTAssertTrue(unique.values().contains("unique"))
        XCTAssertTrue(unique.values().contains("another"))
        
        // Should keep first occurrence of duplicates
        XCTAssertEqual(unique["a"], "duplicate")
        XCTAssertNil(unique["c"]) // Second occurrence should be filtered out
    }
    
    // MARK: - Transform and Filter Tests
    
    func testTransformAndFilter() {
        let dict: TrieDictionary<Int> = ["a": 1, "b": 2, "c": 3, "d": 4]
        
        let transformed: TrieDictionary<Int> = dict.transformAndFilter { element in
            // Only transform even values, double them, and uppercase the key
            guard element.value % 2 == 0 else { return nil }
            return (element.key.uppercased(), element.value * 2)
        }
        
        XCTAssertEqual(transformed.count, 2)
        XCTAssertEqual(transformed["B"], 4)  // 2 * 2
        XCTAssertEqual(transformed["D"], 8)  // 4 * 2
        XCTAssertNil(transformed["A"])
        XCTAssertNil(transformed["C"])
    }
    
    // MARK: - Prefix/Suffix Manipulation Tests
    
    func testAddingPrefix() {
        let dict: TrieDictionary<Int> = ["apple": 1, "banana": 2]
        
        let prefixed = dict.addingPrefix("fruit_")
        XCTAssertEqual(prefixed.count, 2)
        XCTAssertEqual(prefixed["fruit_apple"], 1)
        XCTAssertEqual(prefixed["fruit_banana"], 2)
        XCTAssertNil(prefixed["apple"])
        XCTAssertNil(prefixed["banana"])
    }


    
    // MARK: - Path Values Tests
    
    func testGatheringValuesAlongPaths() {
        let dict: TrieDictionary<Int> = ["a": 1, "ab": 2, "abc": 3, "b": 4]
        
        let pathValues = dict.gatheringValuesAlongPaths(["abc", "ab", "xyz"])
        XCTAssertEqual(pathValues.count, 2)
        XCTAssertEqual(pathValues["abc"], [1, 2, 3])
        XCTAssertEqual(pathValues["ab"], [1, 2])
        XCTAssertNil(pathValues["xyz"])  // No values found along this path
    }
    
    // MARK: - Subtrie Tests
    
    func testSubtrie() {
        let dict: TrieDictionary<Int> = ["apple": 1, "application": 2, "apply": 3, "banana": 4]
        
        let appSubtrie = dict.subtrie(at: "app")
        XCTAssertEqual(appSubtrie.count, 3)
        XCTAssertEqual(appSubtrie["le"], 1)
        XCTAssertEqual(appSubtrie["lication"], 2)
        XCTAssertEqual(appSubtrie["ly"], 3)
        XCTAssertNil(appSubtrie["banana"])
    }
    
    // MARK: - Edge Cases
    
    func testEmptyDictionaryOperations() {
        let dict = TrieDictionary<Int>()
        
        XCTAssertTrue(dict.withPrefix("test").isEmpty)
        XCTAssertTrue(dict.filteringKeys { _ in true }.isEmpty)
        XCTAssertTrue(dict.addingPrefix("prefix").isEmpty)
        XCTAssertTrue(dict.subtrie(at: "any").isEmpty)
    }
}
