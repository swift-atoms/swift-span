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
            name: "Span",
            targets: ["Span"]
        ),
        .library(
            name: "Span Standard Library Integration",
            targets: ["Span Standard Library Integration"]
        ),
        .library(
            name: "Span Apple Foundation Integration",
            targets: ["Span Apple Foundation Integration"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Span",
            dependencies: []
        ),
        .target(
            name: "Span Standard Library Integration",
            dependencies: ["Span"]
        ),
        .target(
            name: "Span Apple Foundation Integration",
            dependencies: [
                "Span",
                "Span Standard Library Integration",
            ]
        ),
        .testTarget(
            name: "Span Tests",
            dependencies: ["Span"]
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
