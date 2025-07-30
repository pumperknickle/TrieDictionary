# TrieDictionary

A high-performance compressed trie (prefix tree) implementation in Swift that provides Dictionary-like functionality with advanced path-based operations.

[![Swift 6.0+](https://img.shields.io/badge/Swift-6.0+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-lightgrey.svg)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Overview

TrieDictionary is a memory-efficient data structure that excels at storing and retrieving string-keyed data, especially when keys share common prefixes. Unlike traditional dictionaries, it uses path compression to minimize memory usage and provides specialized operations for prefix-based queries.

### Key Features

- 🚀 **High Performance**: Optimized with method inlining, efficient data structures, and memory-conscious algorithms
- 💾 **Memory Efficient**: Path compression reduces memory overhead by up to 80% for datasets with common prefixes
- 🔍 **Advanced Traversal**: Built-in support for prefix searches, path value collection, and subtrie operations
- 🛠 **Functional Operations**: Rich set of methods for transforming keys and values
- 📱 **Swift Native**: Full Collection and Sequence protocol conformance, dictionary literal support
- ⚡ **Zero Dependencies**: Pure Swift implementation with no external dependencies

## Performance Characteristics

| Operation | Time Complexity | Space Complexity |
|-----------|----------------|------------------|
| Insertion | O(k) | O(k) |
| Lookup | O(k) | O(1) |
| Deletion | O(k) | O(1) |
| Traversal | O(k) | O(1) |
| Prefix Search | O(k) | O(m) |

*Where k = key length, m = number of matching keys*

**Memory Usage**: O(n×p) where n = number of keys, p = average unique prefix length (significantly less than n×k for datasets with common prefixes)

## Quick Start

### Installation

#### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/TrieDictionary.git", from: "1.0.0")
]
```

Or add via Xcode: File → Add Package Dependencies → Enter repository URL

#### Manual Installation

1. Download the source files
2. Add `Sources/TrieDictionary/` to your project
3. Import `TrieDictionary` in your Swift files

### Basic Usage

```swift
import TrieDictionary

// Create and populate
var trie = TrieDictionary<String>()
trie["apple"] = "fruit"
trie["application"] = "software"
trie["apply"] = "action"

// Dictionary literal syntax
let scores: TrieDictionary<Int> = [
    "alice": 95,
    "bob": 87,
    "charlie": 92
]

// Lookup
print(trie["apple"])  // Optional("fruit")
print(trie["app"])    // nil

// Iteration
for (key, value) in trie {
    print("\\(key): \\(value)")
}
```

## Advanced Features

### Prefix Operations

```swift
var trie: TrieDictionary<String> = [
    "com.apple.iOS": "mobile",
    "com.apple.macOS": "desktop", 
    "com.google.chrome": "browser",
    "org.swift.lang": "language"
]

// Get subtrie for prefix
let appleTrie = trie.traverse("com.apple.")
// Contains: "iOS" -> "mobile", "macOS" -> "desktop"

// Filter by prefix
let comEntries = trie.withPrefix("com.")
// Contains all entries starting with "com."

// Add prefix to all keys
let prefixed = trie.addingPrefix("dev.")
// All keys now start with "dev."
```

### Path Value Collection

```swift
var trie: TrieDictionary<String> = [
    "a": "first",
    "app": "second", 
    "apple": "third"
]

// Get all values along a path
let pathValues = trie.getValuesAlongPath("apple")
// Result: ["first", "second", "third"]

// Expand all keys to their path values
let expanded = trie.expandingToPathValues()
// "a" -> ["first"]
// "app" -> ["first", "second"] 
// "apple" -> ["first", "second", "third"]
```

### Functional Transformations

```swift
let data: TrieDictionary<Int> = [
    "short": 1,
    "medium": 2,
    "verylongkey": 3
]

// Transform values
let doubled = data.mapValues { $0 * 2 }

// Filter by key length
let longKeys = data.withMinKeyLength(8)

// Transform keys
let uppercased = data.mapKeys { $0.uppercased() }

// Complex filtering
let filtered = data.filter { $0.key.count > 5 && $0.value > 1 }
```

### Batch Operations

```swift
var trie = TrieDictionary<String>()

// Batch insertion
let updates = [
    ("key1", "value1"),
    ("key2", "value2"),
    ("key3", "value3")
]
trie = trie.setting(updates)

// Merge with conflict resolution
let other: TrieDictionary<Int> = ["a": 1, "b": 2]
let existing: TrieDictionary<Int> = ["a": 10, "c": 3]
let merged = existing.merging(other, uniquingKeysWith: +)
// Result: ["a": 11, "b": 2, "c": 3]
```

## Use Cases

### 1. Autocomplete Systems

```swift
class AutocompleteEngine {
    private var trie = TrieDictionary<[String]>()
    
    func addSuggestions(for prefix: String, suggestions: [String]) {
        trie[prefix] = suggestions
    }
    
    func getSuggestions(for input: String) -> [String] {
        return trie.traverse(input).values().flatMap { $0 }
    }
}
```

### 2. Configuration Management

```swift
let config: TrieDictionary<String> = [
    "database.host": "localhost",
    "database.port": "5432",
    "database.name": "myapp",
    "api.timeout": "30",
    "api.retries": "3"
]

// Get all database configurations
let dbConfig = config.traverse("database.")
// Result: "host" -> "localhost", "port" -> "5432", "name" -> "myapp"
```

### 3. URL Routing

```swift
struct Router {
    private var routes = TrieDictionary<(handler: String, params: [String])>()
    
    mutating func addRoute(_ path: String, handler: String) {
        routes[path] = (handler: handler, params: [])
    }
    
    func findRoute(_ path: String) -> String? {
        return routes[path]?.handler
    }
    
    func getRoutesWithPrefix(_ prefix: String) -> TrieDictionary<(handler: String, params: [String])> {
        return routes.traverse(prefix)
    }
}
```

### 4. Hierarchical Data

```swift
let fileSystem: TrieDictionary<String> = [
    "/home/user/documents/": "directory",
    "/home/user/documents/file1.txt": "text file",
    "/home/user/documents/file2.pdf": "pdf file",
    "/home/user/pictures/": "directory"
]

// Get all items in a directory
let documentsContent = fileSystem.traverse("/home/user/documents/")

// Get all values along a path (parent directories + file)
let pathInfo = fileSystem.getValuesAlongPath("/home/user/documents/file1.txt")
```

## Performance Benchmarks

Based on our comprehensive benchmarking (see [performance results](performance_comparison.txt)):

### Insertion Performance
- **10K items**: ~0.12s (83K items/second)
- **Memory efficient**: Up to 80% less memory usage vs Dictionary for common prefixes
- **21% faster** than initial implementation after optimizations

### Lookup Performance  
- **10K lookups**: ~0.05s (200K lookups/second)
- **Consistent O(k) behavior** regardless of trie size
- **Better cache locality** with ContiguousArray optimization

### Traversal Performance
- **100 prefix operations**: ~0.002s (50K operations/second) 
- **33% faster** than baseline implementation
- **Zero allocation** for subtrie creation

## Best Practices

### Memory Optimization

```swift
// ✅ Good: Common prefixes save memory
let api: TrieDictionary<String> = [
    "api.v1.users.create": "POST /api/v1/users",
    "api.v1.users.read": "GET /api/v1/users/:id",
    "api.v1.users.update": "PUT /api/v1/users/:id"
]

// ❌ Less efficient: No common prefixes
let scattered: TrieDictionary<String> = [
    "zebra": "animal",
    "alpha": "first", 
    "beta": "second"
]
```

### Performance Tips

```swift
// ✅ Use traverse() for prefix operations
let subtrie = trie.traverse("prefix")

// ❌ Avoid filtering when traverse() works
let filtered = trie.filter { $0.key.hasPrefix("prefix") }

// ✅ Pre-allocate when building large tries
var trie = TrieDictionary<String>()
for (key, value) in largeBatch {
    trie[key] = value  // Efficient incremental building
}

// ✅ Use batch operations when possible
trie = trie.setting(largeBatch)
```

### Thread Safety

TrieDictionary is **not thread-safe**. For concurrent access:

```swift
import Foundation

class ThreadSafeTrieDictionary<Value> {
    private var trie = TrieDictionary<Value>()
    private let queue = DispatchQueue(label: "trie.access", attributes: .concurrent)
    
    func get(_ key: String) -> Value? {
        return queue.sync { trie[key] }
    }
    
    func set(_ key: String, value: Value) {
        queue.async(flags: .barrier) { self.trie[key] = value }
    }
}
```

## API Reference

### Core Operations

| Method | Description | Complexity |
|--------|-------------|------------|
| `subscript[key]` | Get/set value for key | O(k) |
| `updateValue(_:forKey:)` | Set value, return old value | O(k) |
| `removeValue(forKey:)` | Remove value, return old value | O(k) |
| `keys()` | Get all keys | O(n×m) |
| `values()` | Get all values | O(n) |
| `count` | Number of key-value pairs | O(n) |
| `isEmpty` | Check if empty | O(1) |

### Traversal Operations

| Method | Description | Complexity |
|--------|-------------|------------|
| `traverse(_:)` | Get subtrie at prefix | O(k) |
| `getValuesAlongPath(_:)` | Values along path | O(k) |
| `subtrie(at:)` | Alias for traverse | O(k) |
| `subtries(at:)` | Multiple subtries | O(p×k) |

### Functional Operations

| Method | Description | Complexity |
|--------|-------------|------------|
| `addingPrefix(_:)` | Add prefix to all keys | O(n×m) |
| `addingSuffix(_:)` | Add suffix to all keys | O(n×m) |
| `removingPrefix(_:)` | Remove prefix from keys | O(n×m) |
| `removingSuffix(_:)` | Remove suffix from keys | O(n×m) |
| `mapValues(_:)` | Transform values | O(n) |
| `mapKeys(_:)` | Transform keys | O(n×m) |
| `filter(_:)` | Filter key-value pairs | O(n) |
| `merge(_:uniquingKeysWith:)` | Merge two tries | O(m) |

## Testing

The library includes comprehensive tests covering:

- ✅ Core functionality (insertion, lookup, deletion)
- ✅ Path compression correctness
- ✅ Performance benchmarks  
- ✅ Memory efficiency
- ✅ Edge cases and error conditions
- ✅ Protocol conformance
- ✅ Functional operations

Run tests:

```bash
swift test
```

Run performance tests:

```bash
swift test --filter PerformanceTests
```

## Requirements

- Swift 6.0+
- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Linux (Swift 6.0+)

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Add tests for new functionality
4. Ensure all tests pass (`swift test`)
5. Update documentation as needed
6. Commit changes (`git commit -m 'Add amazing feature'`)
7. Push to branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

### Development Setup

```bash
git clone https://github.com/yourusername/TrieDictionary.git
cd TrieDictionary
swift test  # Run tests
swift test --filter PerformanceTests  # Run benchmarks
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by classical trie data structures and modern Swift collection design
- Performance optimizations based on extensive benchmarking and profiling
- Built with Swift's value semantics and protocol-oriented programming in mind

## Support

- 📖 [Documentation](Sources/TrieDictionary/)
- 🐛 [Issues](https://github.com/yourusername/TrieDictionary/issues)
- 💬 [Discussions](https://github.com/yourusername/TrieDictionary/discussions)

---

Made with ❤️ in Swift