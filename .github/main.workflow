workflow "Build and test" {
  on = "push"
  resolves = ["Swift4.2"]
}

action "Swift4.2" {
  uses = "nodes-vapor/github-actions/actions/vapor/swift-4-2@develop"
}
