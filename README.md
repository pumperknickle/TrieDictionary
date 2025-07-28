# TrieDictionary

A high-performance trie-based dictionary implementation in Swift that provides the same interface as Swift's standard `Dictionary` while offering superior performance for string keys with common prefixes.

## Features

- **Efficient Memory Usage**: Uses Hash-Array Mapped Trie (HAMT) concepts for compressed storage
- **Fast Operations**: Optimized for string keys with O(k) complexity where k is the key length
- **Dictionary-Compatible Interface**: Drop-in replacement for `Dictionary<String, Value>`
- **Collection Conformance**: Full support for Swift's collection protocols
- **Functional Operations**: Immutable update and remove operations that return new instances
- **Immutable Operations**: Internal nodes are immutable for thread safety
- **Unicode Support**: Full support for Unicode strings including emojis

## Performance Benefits

TrieDictionary is particularly efficient when:
- Keys share common prefixes (e.g., URLs, file paths, namespaced identifiers)
- Memory usage is a concern with large string key sets
- You need fast prefix-based operations

## Usage

### Basic Operations

```swift
import TrieDictionary

var dict = TrieDictionary<Int>()

// Insert values
dict["hello"] = 1
dict["world"] = 2

// Access values
print(dict["hello"]) // Optional(1)

// Update values
dict.updateValue(10, forKey: "hello")

// Remove values
dict.removeValue(forKey: "world")
```

### Dictionary Literal Support

```swift
let dict: TrieDictionary<String> = [
    "apple": "fruit",
    "car": "vehicle",
    "book": "item"
]
```

### Collection Operations

```swift
// Iteration
for (key, value) in dict {
    print("\(key): \(value)")
}

// Map values
let doubled = dict.mapValues { $0 * 2 }

// Filter
let filtered = dict.filter { $0.value > 5 }

// Merge dictionaries
let merged = dict1.merging(dict2) { old, new in new }
```

### Keys and Values

```swift
let keys = dict.keys()     // [String]
let values = dict.values() // [Value]
```

### Functional Operations

TrieDictionary provides functional programming methods that return new instances instead of mutating the original:

```swift
let original: TrieDictionary<Int> = ["a": 1, "b": 2]

// Setting values (returns new dictionary)
let updated = original.setting(key: "c", value: 3)
let multiUpdate = original.setting(("x", 10), ("y", 20), ("z", 30))

// Updating with old value returned
let (newDict, oldValue) = original.updatingValue(100, forKey: "a")

// Removing keys (returns new dictionary)
let removed = original.removing(key: "b")
let multiRemove = original.removing("a", "b", "nonexistent")

// Removing with old value returned  
let (newDict2, removedValue) = original.removingValue(forKey: "a")

// Conditional operations
let filtered = original.removingAll { $0.value < 2 }
let kept = original.keepingOnly { $0.key.hasPrefix("app") }

// Method chaining
let result = original
    .setting(key: "new", value: 999)
    .removing("b")
    .keepingOnly { $0.value > 1 }
```

**Benefits of Functional Operations:**
- **Immutability**: Original dictionary remains unchanged
- **Thread Safety**: Safe for concurrent access
- **Method Chaining**: Fluent API for complex transformations
- **Structural Sharing**: Efficient memory usage through shared internal nodes

## Architecture

### HAMT-Inspired Design

The implementation uses concepts from Hash-Array Mapped Tries:

1. **Compressed Child Arrays**: Uses bitmaps to efficiently store sparse child nodes
2. **Bit Manipulation**: Leverages popcount operations for fast index calculations  
3. **Path Compression**: Optimizes memory usage for nodes with single children
4. **Immutable Nodes**: Structural sharing for memory efficiency and thread safety

### Key Components

- `TrieDictionary<Value>`: Main dictionary interface
- `TrieNode<Value>`: Internal trie node with compressed storage
- `CompressedChildArray<Value>`: Efficient child node storage using bitmaps

## Installation

### Swift Package Manager

Add this to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/TrieDictionary.git", from: "1.0.0")
]
```

## Requirements

- Swift 5.9+
- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+

## Performance

The library includes comprehensive performance tests comparing against standard Dictionary operations. TrieDictionary excels with:

- **Common Prefixes**: Up to 50% memory reduction for keys with shared prefixes
- **Large Key Sets**: Consistent O(k) performance regardless of dictionary size
- **Unicode Keys**: Efficient handling of Unicode strings and emojis

## Testing

Run the test suite:

```bash
swift test
```

The test suite includes:
- Unit tests for all dictionary operations
- Performance benchmarks
- Unicode and edge case testing
- Memory efficiency validation

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is available under the MIT license.