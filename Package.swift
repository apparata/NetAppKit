// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "NetAppKit",
    platforms: [
        .macOS(.v10_14)
    ],
    products: [
        .library(name: "NetAppKit", targets: ["NetAppKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.7.0"),
    ],
    targets: [
        .target(
            name: "NetAppKit",
            dependencies: [
                "NIO",
                "NIOHTTP1"
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release)),
                .define("SWIFT_PACKAGE")
            ]),
        .target(
            name: "Example",
            dependencies: [
                "NetAppKit"
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release)),
                .define("SWIFT_PACKAGE")
            ]),
        .testTarget(
            name: "NetAppKitTests",
            dependencies: ["NetAppKit"]),
    ]
)
