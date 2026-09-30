// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-span",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "Span", targets: ["Span"]),

        .library(name: "Span Foundation Integration", targets: ["Span Foundation Integration"]),
        .library(name: "Span Test Support", targets: ["Span Test Support"]),
    ],
    traits: [
        .trait(name: "Iterator", description: "Iterator integration"),
        .trait(name: "Byte", description: "Byte integration"),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-tagged.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-byte.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-iterator.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-cardinal.git", branch: "main"),

        .package(
            url: "https://github.com/swift-atoms/swift-index.git",
            branch: "main"
        ),

        .package(
            url: "https://github.com/swift-atoms/swift-ordinal.git",
            branch: "main"
        ),
    ],
    targets: [
        .testTarget(
            name: "Absorbed swift-span-byte Tests",
            dependencies: [
                .target(name: "Span", condition: .when(traits: ["Byte"])),
            ],
            path: "Tests/Absorbed swift-span-byte Tests"
        ),
        .testTarget(
            name: "Absorbed swift-memory-span Tests",
            dependencies: [
                .target(name: "Span"),
            ],
            path: "Tests/Absorbed swift-memory-span Tests"
        ),
        .testTarget(
            name: "Absorbed swift-memory-iterator Tests",
            dependencies: [
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Iterator", package: "swift-iterator"),
                .target(name: "Span", condition: .when(traits: ["Iterator"])),
            ],
            path: "Tests/Absorbed swift-memory-iterator Tests"
        ),
        .target(
            name: "Span",
            dependencies: [
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Iterator", package: "swift-iterator"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Ordinal", package: "swift-ordinal"),
            ],
            path: "Sources/Span"
        ),

        .target(
            name: "Span Foundation Integration",
            dependencies: [
                .target(name: "Span"),
            ],
            path: "Sources/Span Foundation Integration"
        ),
        .target(
            name: "Span Test Support",
            dependencies: [
                .target(name: "Span"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Span Tests",
            dependencies: [
                .product(name: "Cardinal", package: "swift-cardinal"),
                .target(name: "Span"),
                .target(name: "Span Test Support"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Ordinal", package: "swift-ordinal"),
                .target(name: "Span Foundation Integration"),
            ],
            path: "Tests/Span Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets {
    target.swiftSettings = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
}
