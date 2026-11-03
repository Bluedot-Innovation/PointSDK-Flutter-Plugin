// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "bluedot_point_sdk",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "bluedot-point-sdk",
            targets: ["bluedot_point_sdk"]
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
            name: "BluedotPointSdkObjC",
            path: "Sources/BluedotPointSdkObjC",
            publicHeadersPath: "include"
        ),
        .target(
            name: "bluedot_point_sdk",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "BDPointSDK", package: "PointSDK-iOS"),
                "BluedotPointSdkObjC"
            ],
            path: "Sources/bluedot_point_sdk"
        )
    ]
)