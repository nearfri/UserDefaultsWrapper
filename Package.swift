// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UserDefaultsWrapper",
    platforms: [.macOS(.v11), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(name: "UserDefaultsWrapper", targets: ["UserDefaultsWrapper"]),
        .library(name: "UserDefaultsWrapperPlus", targets: ["UserDefaultsWrapperPlus"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nearfri/ObjectCoder", from: "1.0.4"),
    ],
    targets: [
        .target(
            name: "UserDefaultsWrapper",
            dependencies: ["UserDefaultsWrapperUtil"]),
        .testTarget(
            name: "UserDefaultsWrapperTests",
            dependencies: ["UserDefaultsWrapper"]),
        
        .target(
            name: "UserDefaultsWrapperPlus",
            dependencies: ["UserDefaultsWrapper", "UserDefaultsWrapperUtil", "ObjectCoder"]),
        .testTarget(
            name: "UserDefaultsWrapperPlusTests",
            dependencies: ["UserDefaultsWrapperPlus"]),
        
        .target(
            name: "UserDefaultsWrapperUtil",
            dependencies: []),
        .testTarget(
            name: "UserDefaultsWrapperUtilTests",
            dependencies: ["UserDefaultsWrapperUtil"]),
    ]
)
