workflow "Build and test" {
  on = "push"
  resolves = ["Swift 4.2"]
}

action "Swift 4.2" {
  uses = "nodes-vapor/github-actions/actions/vapor/swift-4-2@develop"
}

workflow "Lint" {
  on = "push"
  resolves = ["SwiftLint"]
}

action "SwiftLint" {
  uses = "norio-nomura/action-swiftlint@master"
  secrets = ["GITHUB_TOKEN"]
}
