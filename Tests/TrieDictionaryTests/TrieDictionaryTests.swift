import XCTest
@testable import TrieDictionary

final class TrieDictionaryTests: XCTestCase {
    
    func testEmptyDictionary() {
        let dict = TrieDictionary<Int>()
        XCTAssertTrue(dict.isEmpty)
        XCTAssertEqual(dict.count, 0)
        XCTAssertNil(dict["any"])
    }
    
    func testBasicOperations() {
        var dict = TrieDictionary<Int>()
        
        dict["hello"] = 1
        XCTAssertFalse(dict.isEmpty)
        XCTAssertEqual(dict.count, 1)
        XCTAssertEqual(dict["hello"], 1)
        
        dict["world"] = 2
        XCTAssertEqual(dict.count, 2)
        XCTAssertEqual(dict["world"], 2)
        
        dict["hello"] = 10
        XCTAssertEqual(dict.count, 2)
        XCTAssertEqual(dict["hello"], 10)
    }
    
    func testSettingEmptyKey() {
        var dict = TrieDictionary<Int>()
        dict[""] = 1
        XCTAssertEqual(dict.count, 1)
        XCTAssertEqual(dict[""], 1)
        XCTAssertEqual(dict.rootValue, 1)
    }
    
    func testUpdateValue() {
        var dict = TrieDictionary<String>()
        
        let oldValue1 = dict.updateValue("first", forKey: "key")
        XCTAssertNil(oldValue1)
        XCTAssertEqual(dict["key"], "first")
        
        let oldValue2 = dict.updateValue("second", forKey: "key")
        XCTAssertEqual(oldValue2, "first")
        XCTAssertEqual(dict["key"], "second")
    }
    
    func testRemoveValue() {
        var dict = TrieDictionary<Int>()
        dict["a"] = 1
        dict["ab"] = 2
        dict["abc"] = 3
        
        let removed = dict.removeValue(forKey: "ab")
        XCTAssertEqual(removed, 2)
        XCTAssertEqual(dict.count, 2)
        XCTAssertNil(dict["ab"])
        XCTAssertEqual(dict["a"], 1)
        XCTAssertEqual(dict["abc"], 3)
        
        let nonExistent = dict.removeValue(forKey: "xyz")
        XCTAssertNil(nonExistent)
        XCTAssertEqual(dict.count, 2)
    }
    
    func testRemoveAll() {
        var dict = TrieDictionary<Int>()
        dict["a"] = 1
        dict["b"] = 2
        dict["c"] = 3
        
        XCTAssertEqual(dict.count, 3)
        dict.removeAll()
        XCTAssertTrue(dict.isEmpty)
        XCTAssertEqual(dict.count, 0)
    }
    
    func testPrefixedKeys() {
        var dict = TrieDictionary<Int>()
        dict["a"] = 1
        dict["ab"] = 2
        dict["abc"] = 3
        dict["abcd"] = 4
        dict["b"] = 5
        
        XCTAssertEqual(dict.count, 5)
        XCTAssertEqual(dict["a"], 1)
        XCTAssertEqual(dict["ab"], 2)
        XCTAssertEqual(dict["abc"], 3)
        XCTAssertEqual(dict["abcd"], 4)
        XCTAssertEqual(dict["b"], 5)
    }
    
    func testKeysAndValues() {
        var dict = TrieDictionary<String>()
        dict["apple"] = "fruit"
        dict["car"] = "vehicle"
        dict["book"] = "item"
        
        let keys = Set(dict.keys())
        let values = Set(dict.values())
        
        XCTAssertEqual(keys, Set(["apple", "car", "book"]))
        XCTAssertEqual(values, Set(["fruit", "vehicle", "item"]))
    }
    
    func testIteration() {
        var dict = TrieDictionary<Int>()
        dict["one"] = 1
        dict["two"] = 2
        dict["three"] = 3
        
        var iteratedPairs: [(String, Int)] = []
        for (key, value) in dict {
            iteratedPairs.append((key, value))
        }
        
        XCTAssertEqual(iteratedPairs.count, 3)
        let iteratedDict = Dictionary(uniqueKeysWithValues: iteratedPairs)
        XCTAssertEqual(iteratedDict["one"], 1)
        XCTAssertEqual(iteratedDict["two"], 2)
        XCTAssertEqual(iteratedDict["three"], 3)
    }
    
    func testDictionaryLiteral() {
        let dict: TrieDictionary<String> = ["hello": "world", "foo": "bar"]
        XCTAssertEqual(dict.count, 2)
        XCTAssertEqual(dict["hello"], "world")
        XCTAssertEqual(dict["foo"], "bar")
    }
    
    func testStringDescription() {
        let dict: TrieDictionary<Int> = ["a": 1, "b": 2]
        let description = dict.description
        XCTAssertTrue(description.contains("\"a\": 1"))
        XCTAssertTrue(description.contains("\"b\": 2"))
    }
    
    func testMapValues() {
        let dict: TrieDictionary<Int> = ["a": 1, "b": 2, "c": 3]
        let mapped = dict.mapValues { $0 * 2 }
        
        XCTAssertEqual(mapped["a"], 2)
        XCTAssertEqual(mapped["b"], 4)
        XCTAssertEqual(mapped["c"], 6)
    }
    
    func testCompactMapValues() {
        let dict: TrieDictionary<Int> = ["a": 1, "b": 2, "c": 3, "d": 4]
        let mapped = dict.compactMapValues { $0 % 2 == 0 ? $0 : nil }
        
        XCTAssertEqual(mapped.count, 2)
        XCTAssertEqual(mapped["b"], 2)
        XCTAssertEqual(mapped["d"], 4)
        XCTAssertNil(mapped["a"])
        XCTAssertNil(mapped["c"])
    }
    
    func testFilter() {
        let dict: TrieDictionary<Int> = ["a": 1, "b": 2, "c": 3, "d": 4]
        let filtered = dict.filter { $0.value > 2 }
        
        XCTAssertEqual(filtered.count, 2)
        XCTAssertEqual(filtered["c"], 3)
        XCTAssertEqual(filtered["d"], 4)
        XCTAssertNil(filtered["a"])
        XCTAssertNil(filtered["b"])
    }
    
    func testMerge() {
        var dict1: TrieDictionary<Int> = ["a": 1, "b": 2]
        let dict2: TrieDictionary<Int> = ["b": 20, "c": 3]
        
        dict1.merge(dict2) { old, new in old + new }
        
        XCTAssertEqual(dict1.count, 3)
        XCTAssertEqual(dict1["a"], 1)
        XCTAssertEqual(dict1["b"], 22)
        XCTAssertEqual(dict1["c"], 3)
    }
    
    func testMerging() {
        let dict1: TrieDictionary<String> = ["a": "hello", "b": "world"]
        let dict2: TrieDictionary<String> = ["b": "Swift", "c": "language"]
        
        let merged = dict1.merging(dict2) { _, new in new }
        
        XCTAssertEqual(merged.count, 3)
        XCTAssertEqual(merged["a"], "hello")
        XCTAssertEqual(merged["b"], "Swift")
        XCTAssertEqual(merged["c"], "language")
        
        XCTAssertEqual(dict1["b"], "world")
    }
    
    func testPerformance() {
        measure {
            var dict = TrieDictionary<Int>()
            
            for i in 0..<1000 {
                dict["key\(i)"] = i
            }
            
            for i in 0..<1000 {
                _ = dict["key\(i)"]
            }
            
            for i in 0..<500 {
                dict.removeValue(forKey: "key\(i)")
            }
        }
    }
    
    func testUnicodeKeys() {
        var dict = TrieDictionary<String>()
        dict["🚀"] = "rocket"
        dict["🌟"] = "star"
        dict["café"] = "coffee"
        dict["résumé"] = "cv"
        
        XCTAssertEqual(dict.count, 4)
        XCTAssertEqual(dict["🚀"], "rocket")
        XCTAssertEqual(dict["🌟"], "star")
        XCTAssertEqual(dict["café"], "coffee")
        XCTAssertEqual(dict["résumé"], "cv")
    }
    
    func testEmptyStringKey() {
        var dict = TrieDictionary<String>()
        dict[""] = "empty"
        dict["a"] = "letter"
        
        XCTAssertEqual(dict.count, 2)
        XCTAssertEqual(dict[""], "empty")
        XCTAssertEqual(dict["a"], "letter")
        
        dict[""] = nil
        XCTAssertEqual(dict.count, 1)
        XCTAssertNil(dict[""])
        XCTAssertEqual(dict["a"], "letter")
    }
    
    func testTraverseBasic() {
        var dict = TrieDictionary<Int>()
        dict["apple"] = 1
        dict["application"] = 2
        dict["apply"] = 3
        dict["banana"] = 4
        
        let appSubtrie = dict.traverse("app")
        XCTAssertEqual(appSubtrie.count, 3)
        XCTAssertEqual(appSubtrie["le"], 1)
        XCTAssertEqual(appSubtrie["lication"], 2)
        XCTAssertEqual(appSubtrie["ly"], 3)
        XCTAssertNil(appSubtrie["banana"])
    }
    
    func testTraverseExactMatch() {
        var dict = TrieDictionary<String>()
        dict["hello"] = "world"
        dict["help"] = "me"
        
        let helloSubtrie = dict.traverse("hello")
        XCTAssertEqual(helloSubtrie.count, 1)
        XCTAssertEqual(helloSubtrie[""], "world")
        
        let helpSubtrie = dict.traverse("help")
        XCTAssertEqual(helpSubtrie.count, 1)
        XCTAssertEqual(helpSubtrie[""], "me")
    }
    
    func testTraverseNoMatch() {
        var dict = TrieDictionary<Int>()
        dict["apple"] = 1
        dict["banana"] = 2
        
        let nonExistentSubtrie = dict.traverse("orange")
        XCTAssertTrue(nonExistentSubtrie.isEmpty)
        XCTAssertEqual(nonExistentSubtrie.count, 0)
    }
    
    func testTraverseEmptyPrefix() {
        var dict = TrieDictionary<String>()
        dict["a"] = "first"
        dict["b"] = "second"
        
        let emptyPrefixSubtrie = dict.traverse("")
        XCTAssertEqual(emptyPrefixSubtrie.count, 2)
        XCTAssertEqual(emptyPrefixSubtrie["a"], "first")
        XCTAssertEqual(emptyPrefixSubtrie["b"], "second")
    }
    
    func testTraversePartialPrefix() {
        var dict = TrieDictionary<Int>()
        dict["test"] = 1
        dict["testing"] = 2
        dict["tester"] = 3
        dict["tesla"] = 4
        
        let tesSubtrie = dict.traverse("tes")
        XCTAssertEqual(tesSubtrie.count, 4)
        XCTAssertEqual(tesSubtrie["t"], 1)
        XCTAssertEqual(tesSubtrie["ting"], 2)
        XCTAssertEqual(tesSubtrie["ter"], 3)
        XCTAssertEqual(tesSubtrie["la"], 4)
    }
    
    func testTraverseSingleCharacter() {
        var dict = TrieDictionary<String>()
        dict["a"] = "alpha"
        dict["ab"] = "alphabet"
        dict["abc"] = "abcdef"
        dict["b"] = "beta"
        
        let aSubtrie = dict.traverse("a")
        XCTAssertEqual(aSubtrie.count, 3)
        XCTAssertEqual(aSubtrie[""], "alpha")
        XCTAssertEqual(aSubtrie["b"], "alphabet")
        XCTAssertEqual(aSubtrie["bc"], "abcdef")
        XCTAssertNotEqual(aSubtrie["b"], "beta")
    }
    
    func testTraverseEmptyDictionary() {
        let dict = TrieDictionary<Int>()
        let subtrie = dict.traverse("any")
        XCTAssertTrue(subtrie.isEmpty)
        XCTAssertEqual(subtrie.count, 0)
    }
    
    func testTraverseWithUnicode() {
        var dict = TrieDictionary<String>()
        dict["cafe"] = "coffee"
        dict["cafeteria"] = "restaurant"
        dict["car"] = "vehicle"
        
        let cafeSubtrie = dict.traverse("cafe")
        XCTAssertEqual(dict["cafe"], "coffee")
        XCTAssertEqual(cafeSubtrie.count, 2)
        XCTAssertEqual(cafeSubtrie[""], "coffee")
        XCTAssertEqual(cafeSubtrie["teria"], "restaurant")
    }
    
    func testTraverseReturnsNilForNonExistentPrefix() {
        var dict = TrieDictionary<Int>()
        dict["apple"] = 1
        dict["application"] = 2
        dict["banana"] = 3
        
        let nonExistentSubtrie = dict.traverse("xyz")
        XCTAssertTrue(nonExistentSubtrie.isEmpty)
        XCTAssertEqual(nonExistentSubtrie.count, 0)
        XCTAssertNil(nonExistentSubtrie[""])
        XCTAssertNil(nonExistentSubtrie["any"])
    }
    
    func testTraverseReturnsNilForPrefixNotInPath() {
        var dict = TrieDictionary<String>()
        dict["hello"] = "world"
        dict["help"] = "me"
        
        let mismatchedSubtrie = dict.traverse("helicopter")
        XCTAssertTrue(mismatchedSubtrie.isEmpty)
        XCTAssertEqual(mismatchedSubtrie.count, 0)
    }
    
    func testTraverseReturnsNilForPartialMismatch() {
        var dict = TrieDictionary<Int>()
        dict["test"] = 1
        dict["testing"] = 2
        dict["tesla"] = 3
        
        let mismatchedSubtrie = dict.traverse("tex")
        XCTAssertTrue(mismatchedSubtrie.isEmpty)
        XCTAssertEqual(mismatchedSubtrie.count, 0)
    }
    
    func testTraverseReturnsNilWithSingleCharacterMismatch() {
        var dict = TrieDictionary<String>()
        dict["a"] = "alpha"
        dict["b"] = "beta"
        dict["c"] = "gamma"
        
        let mismatchedSubtrie = dict.traverse("z")
        XCTAssertTrue(mismatchedSubtrie.isEmpty)
        XCTAssertEqual(mismatchedSubtrie.count, 0)
    }
    
    func testTraverseReturnsNilForLongerPrefixThanKeys() {
        var dict = TrieDictionary<Int>()
        dict["a"] = 1
        dict["ab"] = 2
        
        let longerPrefixSubtrie = dict.traverse("abcdefg")
        XCTAssertTrue(longerPrefixSubtrie.isEmpty)
        XCTAssertEqual(longerPrefixSubtrie.count, 0)
    }
    
    func testTraverseReturnsNilForCompressedPathMismatch() {
        var dict = TrieDictionary<String>()
        dict["application"] = "app"
        dict["appreciate"] = "thanks"
        
        let compressedMismatchSubtrie = dict.traverse("approve")
        XCTAssertTrue(compressedMismatchSubtrie.isEmpty)
        XCTAssertEqual(compressedMismatchSubtrie.count, 0)
    }
}
