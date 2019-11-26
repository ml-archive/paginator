// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Paginator",
    products: [
        .library(name: "Paginator", targets: ["Paginator"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/fluent.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/sql.git", from: "2.3.2"),
    ],
    targets: [
        .target(name: "Paginator", dependencies: ["Fluent", "Vapor", "SQL"]),
        .testTarget(name: "PaginatorTests", dependencies: ["Paginator"]),
    ]
)
