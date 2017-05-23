import PackageDescription

let package = Package(
    name: "Paginator",
    dependencies: [
        .Package(url: "https://github.com/vapor/fluent.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor/leaf-provider.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/fluent-provider.git", majorVersion: 1)
    ]
)
