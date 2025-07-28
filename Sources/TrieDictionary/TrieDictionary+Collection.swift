import Foundation

extension TrieDictionary: Collection {
    public typealias Element = (key: String, value: Value)
    public typealias Index = Int
    
    public var startIndex: Index {
        return 0
    }
    
    public var endIndex: Index {
        return count
    }
    
    public func index(after i: Index) -> Index {
        return i + 1
    }
    
    public subscript(position: Index) -> Element {
        let keys = self.keys()
        let key = keys[position]
        let value = self[key]!
        return (key: key, value: value)
    }
}

extension TrieDictionary: Sequence {
    public func makeIterator() -> TrieDictionaryIterator<Value> {
        return TrieDictionaryIterator(dictionary: self)
    }
}

public struct TrieDictionaryIterator<Value>: IteratorProtocol {
    public typealias Element = (key: String, value: Value)
    
    private let keys: [String]
    private let dictionary: TrieDictionary<Value>
    private var currentIndex: Int = 0
    
    internal init(dictionary: TrieDictionary<Value>) {
        self.dictionary = dictionary
        self.keys = dictionary.keys()
    }
    
    public mutating func next() -> Element? {
        guard currentIndex < keys.count else {
            return nil
        }
        
        let key = keys[currentIndex]
        let value = dictionary[key]!
        currentIndex += 1
        
        return (key: key, value: value)
    }
}