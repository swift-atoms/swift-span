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
            name: "Span Primitive",
            targets: ["Span Primitive"]
        ),
        .library(
            name: "Span Protocol",
            targets: ["Span Protocol"]
        ),
        .library(
            name: "Span Raw",
            targets: ["Span Raw"]
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
            url: "https://github.com/swift-molecules/swift-index.git",
            branch: "main"
        ),

        .package(
            url: "https://github.com/swift-molecules/swift-byte.git",
            branch: "main"
        ),

        .package(
            url: "https://github.com/swift-molecules/swift-cardinal.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Span Primitive",
            dependencies: []
        ),
        .target(
            name: "Span Protocol",
            dependencies: [
                "Span Primitive",
                .product(name: "Index", package: "swift-index"),
            ]
        ),
        .target(
            name: "Span Raw",
            dependencies: [
                "Span Primitive",
                "Span Protocol",
                .product(name: "Index", package: "swift-index"),
                .product(name: "Byte", package: "swift-byte"),
                .product(
                    name: "Cardinal Standard Library Integration",
                    package: "swift-cardinal"
                ),
            ]
        ),
        .target(
            name: "Span",
            dependencies: [
                "Span Primitive",
                "Span Protocol",
                "Span Raw",
            ]
        ),
        .target(
            name: "Span Test Support",
            dependencies: [
                "Span"
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Span Tests",
            dependencies: [
                "Span",
                "Span Test Support",
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
