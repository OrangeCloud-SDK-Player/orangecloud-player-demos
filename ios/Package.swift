// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OrangeCloudPlayerDemo",
    platforms: [.iOS(.v16), .macOS(.v13)],
    dependencies: [
        .package(path: "../../ios/OrangeCloudPlayerClient"),
    ],
    targets: [
        .executableTarget(
            name: "OrangeCloudPlayerDemo",
            dependencies: ["OrangeCloudPlayerClient"],
            path: "Sources"
        ),
    ]
)
