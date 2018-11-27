// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Paginator",
    products: [
        .library(name: "Paginator", targets: ["Paginator"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/fluent.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/nodes-vapor/sugar.git", from: "3.0.0-beta"),
    ],
    targets: [
        .target(name: "Paginator", dependencies: ["Fluent", "Vapor", "Sugar"]),
        .testTarget(name: "PaginatorTests", dependencies: ["Paginator"]),
    ]
)
