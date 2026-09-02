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
        .library(
            name: "Span Protocol",
            targets: ["Span Protocol"]
        ),
        .library(
            name: "Span",
            targets: ["Span"]
        ),
        .library(
            name: "Span Test Support",
            targets: ["Span Test Support"]
        ),
    ],
    dependencies: [

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
        .target(
            name: "Span",
            dependencies: []
        ),
        .target(
            name: "Span Protocol",
            dependencies: [
                .target(name: "Span"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Ordinal Protocol", package: "swift-ordinal"),
            ]
        ),
        .target(
            name: "Span Test Support",
            dependencies: [
                .target(name: "Span")
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Span Tests",
            dependencies: [
                .target(name: "Span"),
                .target(name: "Span Protocol"),
                .target(name: "Span Test Support"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Ordinal Protocol", package: "swift-ordinal"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
