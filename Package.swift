// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "CodeField",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "CodeField",
            targets: ["CodeField"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        .target(
            name: "CodeField",
            dependencies: []
        )
    ]
)
