// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftDataHelper",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "SwiftDataHelper",
            targets: ["SwiftDataHelper"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.4.1")
    ],
    targets: [
        .target(
            name: "SwiftDataHelper",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies")
            ]
        ),
        .testTarget(
            name: "SwiftDataHelperTests",
            dependencies: ["SwiftDataHelper"]
        ),
    ]
)

