import XCTest
@testable import TrieDictionary

final class PerformanceTests: XCTestCase {
    
    func testLargeDataSetInsertion() {
        measure {
            var dict = TrieDictionary<Int>()
            for i in 0..<10_000 {
                dict["key_\(i)_suffix"] = i
            }
        }
    }
    
    func testLargeDataSetLookup() {
        var dict = TrieDictionary<Int>()
        for i in 0..<10_000 {
            dict["key_\(i)_suffix"] = i
        }
        
        measure {
            for i in 0..<10_000 {
                _ = dict["key_\(i)_suffix"]
            }
        }
    }
    
    func testCompareWithStandardDictionary() {
        let keys = (0..<1000).map { "prefix_\($0)_suffix_very_long_key" }
        
        measure {
            var trieDict = TrieDictionary<Int>()
            for (index, key) in keys.enumerated() {
                trieDict[key] = index
            }
            
            for key in keys {
                _ = trieDict[key]
            }
        }
    }
    
    func testMemoryEfficiencyWithCommonPrefixes() {
        measure {
            var dict = TrieDictionary<String>()
            
            let commonPrefix = "com.example.app.module.component."
            for i in 0..<1000 {
                dict["\(commonPrefix)item\(i)"] = "value\(i)"
            }
            
            for i in 0..<1000 {
                _ = dict["\(commonPrefix)item\(i)"]
            }
        }
    }
    
    func testIterationPerformance() {
        var dict = TrieDictionary<Int>()
        for i in 0..<5_000 {
            dict["key\(i)"] = i
        }
        
        measure {
            var sum = 0
            for (_, value) in dict {
                sum += value
            }
        }
    }
    
    func testRemovalPerformance() {
        var dict = TrieDictionary<Int>()
        let keys = (0..<1000).map { "key\($0)" }
        
        for (index, key) in keys.enumerated() {
            dict[key] = index
        }
        
        measure {
            for key in keys {
                dict.removeValue(forKey: key)
            }
        }
    }
}