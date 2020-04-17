// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CSV2Keychain",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "csv2keychain", targets: ["CSV2Keychain"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
    ],
    targets: [
        .target(name: "CSV2Keychain", dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ]),
        .testTarget(name: "CSV2KeychainTests", dependencies: ["CSV2Keychain"]),
    ]
)
