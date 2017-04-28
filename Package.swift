import PackageDescription

let package = Package(
    name: "Paginator",
    dependencies: [
        .Package(url: "https://github.com/vapor/fluent.git", Version(2,0,0, prereleaseIdentifiers: ["beta"])),
        .Package(url: "https://github.com/vapor/vapor.git", Version(2,0,0, prereleaseIdentifiers: ["beta"])),
        .Package(url: "https://github.com/vapor/leaf-provider.git", Version(1,0,0, prereleaseIdentifiers: ["beta"])),
        .Package(url: "https://github.com/vapor/fluent-provider.git", Version(1,0,0, prereleaseIdentifiers: ["beta"]))
    ]
)
