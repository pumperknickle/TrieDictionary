// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TrieDictionary",
    products: [
        .library(
            name: "TrieDictionary",
            targets: ["TrieDictionary"]),
    ],
    targets: [
        .target(
            name: "TrieDictionary",
            dependencies: []),
        .testTarget(
            name: "TrieDictionaryTests",
            dependencies: ["TrieDictionary"]),
    ]
)
