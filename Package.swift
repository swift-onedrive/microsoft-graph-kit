// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "microsoft-graph-kit",
    platforms: [
        .macOS(.v11),
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MicrosoftGraphOneDrive",
            targets: ["OneDrive"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/swift-onedrive/microsoft-graph-core.git", from: "0.0.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "OneDrive",
            dependencies: [
                .product(name: "MicrosoftGraphCore", package: "microsoft-graph-core")
            ],
            path: "Sources/OneDrive/Sources/"
        ),
        .executableTarget(
            name: "Run",
            dependencies: [
                .target(name: "OneDrive")
            ],
            path: "Sources/Run/"
        ),
        .testTarget(
            name: "microsoft-graph-kitTests",
            dependencies: ["OneDrive"]),
    ]
)