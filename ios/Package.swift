// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OrangeCloudPlayerDemo",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    dependencies: [
        .package(url: "https://github.com/OrangeCloud-SDK-Player/orangecloud-player-ios.git", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "OrangeCloudPlayerDemo",
            dependencies: [
                .product(name: "OrangeCloudPlayerClient", package: "orangecloud-player-ios")
            ],
            path: "Sources"
        )
    ]
)
