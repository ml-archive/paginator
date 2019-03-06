// swift-tools-version:4.1
import PackageDescription

let package = Package(
    name: "Paginator",
    products: [
        .library(name: "Paginator", targets: ["Paginator"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/fluent.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
    ],
    targets: [
        .target(name: "Paginator", dependencies: ["Fluent", "Vapor"]),
        .testTarget(name: "PaginatorTests", dependencies: ["Paginator"]),
    ]
)
