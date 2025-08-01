import XCTest
@testable import TrieDictionary

final class PerformanceTests: XCTestCase {
    
    // MARK: - Baseline Performance Tests
    
    func testInsertionPerformance() {
        let words = generateTestWords(count: 10000)
        var trie = TrieDictionary<Int>()
        
        measure {
            for (index, word) in words.enumerated() {
                trie[word] = index
            }
        }
    }
    
    func testLookupPerformance() {
        let words = generateTestWords(count: 10000)
        var trie = TrieDictionary<Int>()
        
        // Setup
        for (index, word) in words.enumerated() {
            trie[word] = index
        }
        
        measure {
            for word in words {
                _ = trie[word]
            }
        }
    }
    
    func testTraversalPerformance() {
        let words = generateTestWords(count: 5000)
        var trie = TrieDictionary<Int>()
        
        // Setup
        for (index, word) in words.enumerated() {
            trie[word] = index
        }
        
        let prefixes = Array(words.prefix(100)).map { String($0.prefix(3)) }
        
        measure {
            for prefix in prefixes {
                _ = trie.traverse(prefix)
            }
        }
    }
    
    func testPathValuesPerformance() {
        let words = generateTestWords(count: 5000)
        var trie = TrieDictionary<Int>()
        
        // Setup
        for (index, word) in words.enumerated() {
            trie[word] = index
        }
        
        let paths = Array(words.prefix(1000))
        
        measure {
            for path in paths {
                _ = trie.getValuesAlongPath(path)
            }
        }
    }
    
    func testFunctionalOperationsPerformance() {
        let words = generateTestWords(count: 2000)
        var trie = TrieDictionary<Int>()
        
        // Setup
        for (index, word) in words.enumerated() {
            trie[word] = index
        }
        
        measure {
            _ = trie.addingPrefix("test_")
        }
    }
    
    // MARK: - Original Tests (for compatibility)
    
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
    
    // MARK: - Helper Methods
    
    private func generateTestWords(count: Int) -> [String] {
        var words: [String] = []
        let characters = "abcdefghijklmnopqrstuvwxyz"
        
        for i in 0..<count {
            let wordLength = (i % 15) + 3 // Length between 3-17
            var word = ""
            
            for _ in 0..<wordLength {
                let randomChar = characters.randomElement()!
                word.append(randomChar)
            }
            
            // Add some common prefixes to create more realistic trie structure
            if i % 10 == 0 {
                word = "common_" + word
            } else if i % 15 == 0 {
                word = "test_" + word
            } else if i % 20 == 0 {
                word = "prefix_" + word
            }
            
            words.append(word)
        }
        
        return words
    }
}
