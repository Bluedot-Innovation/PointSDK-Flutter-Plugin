// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "bluedot_point_sdk_push",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "bluedot-point-sdk-push",
            targets: ["bluedot_point_sdk_push"]
        )
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(
            url: "https://github.com/Bluedot-Innovation/PointSDK-iOS",
            exact: "18.1.0"
        )
    ],
    targets: [
        .target(
            name: "bluedot_point_sdk_push",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "BDPointSDK", package: "PointSDK-iOS")
            ],
            path: "Sources/bluedot_point_sdk_push"
        )
    ]
)