// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "gpx-editor-kit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "EditorFeature",
            targets: ["EditorFeature"]
        ),
        .library(
            name: "ElevationClient",
            targets: ["ElevationClient"]
        )
    ], dependencies: [
        .package(url: "https://github.com/mmllr/GPXKit.git", from: "2.2.1"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.7.3"),
        .package(url: "https://github.com/pointfreeco/swift-url-routing", from: "0.6.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.1.1"),
        .package(url: "https://github.com/tgrapperon/swift-dependencies-additions", from: "1.0.1")
        //        .package(url: "https://github.com/pointfreeco/swift-overture", from: "0.5.0")
        //        .package(url: "https://github.com/pointfreeco/swift-concurrency-extras", from: "1.1.0"),
        //        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.5"),
        //        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
        //        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0-beta.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "EditorFeature",
            dependencies: [
                "ElevationClient",
                .gpx,
                .tca

            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "EditorFeatureTests",
            dependencies: ["EditorFeature"]
        ),
        .target(
            name: "ElevationClient",
            dependencies: [
                .gpx,
                .dependencies,
                .dependenciesMacros,
                .urlRouting,
                .dependenciesAdditions
            ]
        )
    ]
)

extension Target.Dependency {
    static let tca: Self = .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
    static let concurrencyExtras: Self = .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras")
    static let navigation: Self = .product(name: "SwiftUINavigation", package: "swiftui-navigation")
    static let identified: Self = .product(name: "IdentifiedCollections", package: "swift-identified-collections")
    static let clocks: Self = .product(name: "Clocks", package: "swift-clocks")
    static let dependencies: Self = .product(name: "Dependencies", package: "swift-dependencies")
    static let dependenciesMacros: Self = .product(name: "DependenciesMacros", package: "swift-dependencies")
    static let dependenciesAdditions: Self = .product(
        name: "DependenciesAdditions",
        package: "swift-dependencies-additions"
    )
    static let tagged: Self = .product(name: "Tagged", package: "swift-tagged")
    static let algorithms: Self = .product(name: "Algorithms", package: "swift-algorithms")
    static let asyncAlgorithms: Self = .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
    static let customDump: Self = .product(name: "CustomDump", package: "swift-custom-dump")
    static let xctDynOverlay: Self = .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
    static let urlRouting: Self = .product(name: "URLRouting", package: "swift-url-routing")
    static let overture: Self = .product(name: "Overture", package: "swift-overture")
    static let schedulers: Self = .product(name: "CombineSchedulers", package: "combine-schedulers")
    static let collections: Self = .product(name: "Collections", package: "swift-collections")
    static let nonEmpty: Self = .product(name: "NonEmpty", package: "swift-nonempty")
    static let gpx: Self = "GPXKit"
}
