import XCTest
@testable import TrieDictionary

final class FunctionalOperationsTests: XCTestCase {
    
    func testFunctionalSetting() {
        let original: TrieDictionary<Int> = ["a": 1, "b": 2]
        let updated = original.setting(key: "c", value: 3)
        
        XCTAssertEqual(original.count, 2)
        XCTAssertEqual(original["c"], nil)
        
        XCTAssertEqual(updated.count, 3)
        XCTAssertEqual(updated["a"], 1)
        XCTAssertEqual(updated["b"], 2)
        XCTAssertEqual(updated["c"], 3)
    }
    
    func testFunctionalSettingOverwrite() {
        let original: TrieDictionary<String> = ["key": "old"]
        let updated = original.setting(key: "key", value: "new")
        
        XCTAssertEqual(original["key"], "old")
        XCTAssertEqual(updated["key"], "new")
        XCTAssertEqual(original.count, 1)
        XCTAssertEqual(updated.count, 1)
    }
    
    func testFunctionalSettingVariadic() {
        let original: TrieDictionary<Int> = ["a": 1]
        let updated = original.setting(("b", 2), ("c", 3), ("d", 4))
        
        XCTAssertEqual(original.count, 1)
        XCTAssertEqual(updated.count, 4)
        XCTAssertEqual(updated["a"], 1)
        XCTAssertEqual(updated["b"], 2)
        XCTAssertEqual(updated["c"], 3)
        XCTAssertEqual(updated["d"], 4)
    }
    
    func testFunctionalSettingSequence() {
        let original: TrieDictionary<String> = ["x": "existing"]
        let pairs = [("a", "apple"), ("b", "banana"), ("c", "cherry")]
        let updated = original.setting(pairs)
        
        XCTAssertEqual(original.count, 1)
        XCTAssertEqual(updated.count, 4)
        XCTAssertEqual(updated["x"], "existing")
        XCTAssertEqual(updated["a"], "apple")
        XCTAssertEqual(updated["b"], "banana")
        XCTAssertEqual(updated["c"], "cherry")
    }
    
    func testFunctionalUpdatingValue() {
        let original: TrieDictionary<Int> = ["existing": 100]
        
        let (newDict, oldValue) = original.updatingValue(200, forKey: "existing")
        XCTAssertEqual(oldValue, 100)
        XCTAssertEqual(original["existing"], 100)
        XCTAssertEqual(newDict["existing"], 200)
        
        let (newDict2, oldValue2) = original.updatingValue(50, forKey: "new")
        XCTAssertNil(oldValue2)
        XCTAssertEqual(original.count, 1)
        XCTAssertEqual(newDict2.count, 2)
        XCTAssertEqual(newDict2["new"], 50)
    }
    
    func testFunctionalRemoving() {
        let original: TrieDictionary<String> = ["a": "apple", "b": "banana", "c": "cherry"]
        let updated = original.removing(key: "b")
        
        XCTAssertEqual(original.count, 3)
        XCTAssertEqual(original["b"], "banana")
        
        XCTAssertEqual(updated.count, 2)
        XCTAssertEqual(updated["a"], "apple")
        XCTAssertEqual(updated["c"], "cherry")
        XCTAssertNil(updated["b"])
    }
    
    func testFunctionalRemovingVariadic() {
        let original: TrieDictionary<Int> = ["a": 1, "b": 2, "c": 3, "d": 4, "e": 5]
        let updated = original.removing("b", "d", "f")
        
        XCTAssertEqual(original.count, 5)
        XCTAssertEqual(updated.count, 3)
        XCTAssertEqual(updated["a"], 1)
        XCTAssertEqual(updated["c"], 3)
        XCTAssertEqual(updated["e"], 5)
        XCTAssertNil(updated["b"])
        XCTAssertNil(updated["d"])
    }
    
    func testFunctionalRemovingSequence() {
        let original: TrieDictionary<String> = ["w": "water", "x": "xray", "y": "yellow", "z": "zebra"]
        let keysToRemove = ["x", "z", "nonexistent"]
        let updated = original.removing(keysToRemove)
        
        XCTAssertEqual(original.count, 4)
        XCTAssertEqual(updated.count, 2)
        XCTAssertEqual(updated["w"], "water")
        XCTAssertEqual(updated["y"], "yellow")
        XCTAssertNil(updated["x"])
        XCTAssertNil(updated["z"])
    }
    
    func testFunctionalRemovingValue() {
        let original: TrieDictionary<Int> = ["key": 42]
        
        let (updated, oldValue) = original.removingValue(forKey: "key")
        XCTAssertEqual(oldValue, 42)
        XCTAssertEqual(original["key"], 42)
        XCTAssertEqual(original.count, 1)
        XCTAssertTrue(updated.isEmpty)
        
        let (updated2, oldValue2) = original.removingValue(forKey: "nonexistent")
        XCTAssertNil(oldValue2)
        XCTAssertEqual(updated2.count, 1)
        XCTAssertEqual(updated2["key"], 42)
    }
    
    func testFunctionalRemovingAll() {
        let original: TrieDictionary<String> = ["a": "apple", "b": "banana"]
        let empty = original.removingAll()
        
        XCTAssertEqual(original.count, 2)
        XCTAssertTrue(empty.isEmpty)
        XCTAssertEqual(empty.count, 0)
    }
    
    func testFunctionalRemovingAllWhere() {
        let original: TrieDictionary<Int> = ["a": 1, "b": 20, "c": 3, "d": 40, "e": 5]
        let filtered = original.removingAll { $0.value >= 10 }
        
        XCTAssertEqual(original.count, 5)
        XCTAssertEqual(filtered.count, 3)
        XCTAssertEqual(filtered["a"], 1)
        XCTAssertEqual(filtered["c"], 3)
        XCTAssertEqual(filtered["e"], 5)
        XCTAssertNil(filtered["b"])
        XCTAssertNil(filtered["d"])
    }
    
    func testFunctionalKeepingOnly() {
        let original: TrieDictionary<String> = [
            "apple": "fruit",
            "carrot": "vegetable",
            "banana": "fruit",
            "broccoli": "vegetable"
        ]
        let fruitsOnly = original.keepingOnly { $0.value == "fruit" }
        
        XCTAssertEqual(original.count, 4)
        XCTAssertEqual(fruitsOnly.count, 2)
        XCTAssertEqual(fruitsOnly["apple"], "fruit")
        XCTAssertEqual(fruitsOnly["banana"], "fruit")
        XCTAssertNil(fruitsOnly["carrot"])
        XCTAssertNil(fruitsOnly["broccoli"])
    }
    
    func testImmutabilityOfOriginal() {
        let original: TrieDictionary<Int> = ["a": 1, "b": 2]
        
        let _ = original
            .setting(key: "c", value: 3)
            .removing(key: "a")
            .setting(("d", 4), ("e", 5))
            .removingAll { $0.value > 3 }
        
        XCTAssertEqual(original.count, 2)
        XCTAssertEqual(original["a"], 1)
        XCTAssertEqual(original["b"], 2)
        XCTAssertNil(original["c"])
        XCTAssertNil(original["d"])
        XCTAssertNil(original["e"])
    }
    
    func testFunctionalChaining() {
        let result = TrieDictionary<String>()
            .setting(key: "initial", value: "value")
            .setting(("a", "apple"), ("b", "banana"), ("c", "cherry"))
            .removing("b")
            .setting(key: "d", value: "date")
            .keepingOnly { $0.key != "initial" }
        
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result["a"], "apple")
        XCTAssertEqual(result["c"], "cherry")
        XCTAssertEqual(result["d"], "date")
        XCTAssertNil(result["initial"])
        XCTAssertNil(result["b"])
    }
    
    func testFunctionalOperationsWithEmptyDictionary() {
        let empty = TrieDictionary<Int>()
        
        let withValue = empty.setting(key: "test", value: 42)
        XCTAssertTrue(empty.isEmpty)
        XCTAssertEqual(withValue.count, 1)
        XCTAssertEqual(withValue["test"], 42)
        
        let stillEmpty = empty.removing(key: "nonexistent")
        XCTAssertTrue(stillEmpty.isEmpty)
        
        let (dict, oldValue) = empty.updatingValue(100, forKey: "new")
        XCTAssertNil(oldValue)
        XCTAssertEqual(dict["new"], 100)
    }
    
    func testPerformanceOfFunctionalOperations() {
        var original = TrieDictionary<Int>()
        for i in 0..<1000 {
            original["key\(i)"] = i
        }
        
        measure {
            let _ = original
                .setting(key: "new1", value: 1001)
                .setting(key: "new2", value: 1002)
                .removing(key: "key500")
                .removing(key: "key501")
                .keepingOnly { $0.value < 900 }
        }
    }
    
    func testTraverseWithFunctionalOperations() {
        let original: TrieDictionary<String> = [
            "apple": "fruit",
            "application": "software",
            "apply": "verb",
            "banana": "fruit",
            "band": "music"
        ]
        
        let appSubtrie = original.traverse("app")
        XCTAssertEqual(appSubtrie.count, 3)
        XCTAssertEqual(appSubtrie["le"], "fruit")
        XCTAssertEqual(appSubtrie["lication"], "software")
        XCTAssertEqual(appSubtrie["ly"], "verb")
        
        let functionalResult = original
            .setting(key: "approach", value: "method")
            .traverse("app")
            .keepingOnly { $0.value != "verb" }
        
        XCTAssertEqual(functionalResult.count, 3)
        XCTAssertEqual(functionalResult["le"], "fruit")
        XCTAssertEqual(functionalResult["lication"], "software")
        XCTAssertEqual(functionalResult["roach"], "method")
        XCTAssertNil(functionalResult["ly"])
    }
    
    func testTraverseImmutability() {
        let original: TrieDictionary<Int> = ["test": 1, "testing": 2, "tester": 3]
        let subtrie = original.traverse("test")
        
        XCTAssertEqual(original.count, 3)
        XCTAssertEqual(original["test"], 1)
        XCTAssertEqual(original["testing"], 2)
        XCTAssertEqual(original["tester"], 3)
        
        XCTAssertEqual(subtrie.count, 3) // Exact match "test" excluded
        XCTAssertEqual(subtrie[""], 1) // Empty keys not supported
        XCTAssertEqual(subtrie["ing"], 2)
        XCTAssertEqual(subtrie["er"], 3)
    }
}
