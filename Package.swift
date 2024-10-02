// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Sevenzip",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "Sevenzip",
            targets: ["SevenzipPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", branch: "main")
    ],
    targets: [
        .target(
            name: "SevenzipPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/SevenzipPlugin"),
        .testTarget(
            name: "SevenzipPluginTests",
            dependencies: ["SevenzipPlugin"],
            path: "ios/Tests/SevenzipPluginTests")
    ]
)