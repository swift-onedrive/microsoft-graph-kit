// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "microsoft-graph-kit",
    platforms: [ .macOS(.v10_15)],
    products: [
        .library(name: "MicrosoftGraphKit",
                 targets: ["Core", "OneDrive"])
        ,
        .library(
            name: "MicrosoftGraphCore",
            targets: ["Core"]
        ),
        .library(name: "MicrosoftGraphOneDrive",
                 targets: ["OneDrive"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.2.0"),
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "4.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Core",
            dependencies: [
                .product(name: "JWTKit", package: "jwt-kit"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
            ],
            path: "Core/Sources/"
        ),
        .target(
            name: "OneDrive",
            dependencies: [
                .target(name: "Core")
            ],
            path: "OneDrive/Sources/"
        ),
        .target(name: "Run", dependencies: [
            .target(name: "Core"),
            .target(name: "OneDrive")
        ])
    ]
)
