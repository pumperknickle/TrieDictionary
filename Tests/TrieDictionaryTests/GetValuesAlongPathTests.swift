import XCTest
@testable import TrieDictionary

class GetValuesAlongPathTests: XCTestCase {
    
    func testGetValuesAlongPathBasic() {
        var dict = TrieDictionary<Int>()
        dict["a"] = 1
        dict["ab"] = 2
        dict["abc"] = 3
        dict["abcd"] = 4
        
        let values = dict.getValuesAlongPath("abcd")
        XCTAssertEqual(values, [1, 2, 3, 4])
    }
    
    func testGetValuesAlongPathPartialPath() {
        var dict = TrieDictionary<String>()
        dict["hello"] = "h"
        dict["hel"] = "he"
        dict["h"] = "start"
        
        let values = dict.getValuesAlongPath("hello")
        XCTAssertEqual(values, ["start", "he", "h"])
    }
    
    func testGetValuesAlongPathNoMatches() {
        var dict = TrieDictionary<Int>()
        dict["apple"] = 1
        dict["banana"] = 2
        
        let values = dict.getValuesAlongPath("orange")
        XCTAssertEqual(values, [])
    }
    
    func testGetValuesAlongPathEmptyPath() {
        var dict = TrieDictionary<Int>()
        dict["a"] = 1
        
        let values = dict.getValuesAlongPath("")
        XCTAssertEqual(values, [])
    }
    
    func testGetValuesAlongPathSingleChar() {
        var dict = TrieDictionary<String>()
        dict["a"] = "found"
        
        let values = dict.getValuesAlongPath("a")
        XCTAssertEqual(values, ["found"])
    }
    
    func testGetValuesAlongPathLongerThanKeys() {
        var dict = TrieDictionary<Int>()
        dict["ab"] = 1
        dict["abc"] = 2
        
        let values = dict.getValuesAlongPath("abcdefgh")
        XCTAssertEqual(values, [1, 2])
    }
    
    func testGetValuesAlongPathCompressedPaths() {
        var dict = TrieDictionary<String>()
        dict["application"] = "app"
        dict["app"] = "short"
        dict["apply"] = "verb"
        
        let values = dict.getValuesAlongPath("application")
        XCTAssertEqual(values, ["short", "app"])
    }
    
    func testGetValuesAlongPathUnicode() {
        var dict = TrieDictionary<Int>()
        dict["🚀"] = 1
        dict["🚀🌟"] = 2
        dict["🚀🌟⭐"] = 3
        
        let values = dict.getValuesAlongPath("🚀🌟⭐")
        XCTAssertEqual(values, [1, 2, 3])
    }
    
    func testGetValuesAlongPathPerformance() {
        var dict = TrieDictionary<Int>()
        
        // Create a deep path structure
        for i in 1...100 {
            let key = String(repeating: "a", count: i)
            dict[key] = i
        }
        
        let longPath = String(repeating: "a", count: 100)
        
        measure {
            for _ in 0..<1000 {
                let values = dict.getValuesAlongPath(longPath)
                XCTAssertEqual(values.count, 100)
                XCTAssertEqual(values.first, 1)
                XCTAssertEqual(values.last, 100)
            }
        }
    }
    
    func testGetValuesAlongPathComplexScenario() {
        var dict = TrieDictionary<String>()
        
        // Create a realistic autocomplete-like structure
        dict["s"] = "s"
        dict["sw"] = "sw"
        dict["swi"] = "swi"
        dict["swif"] = "swif"
        dict["swift"] = "swift"
        dict["swiftly"] = "swiftly"
        
        let values = dict.getValuesAlongPath("swiftly")
        XCTAssertEqual(values, ["s", "sw", "swi", "swif", "swift", "swiftly"])
        
        // Test partial path
        let partialValues = dict.getValuesAlongPath("swif")
        XCTAssertEqual(partialValues, ["s", "sw", "swi", "swif"])
    }
}