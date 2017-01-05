import Vapor

final class PaginatorProvider: Provider {
    var provided: Providable = Providable()
    
    func boot(_ drop: Droplet) {
        guard let renderer = drop.view as? LeafRenderer else {
            print("warning: you are not using Leaf, cannot register Paginator extensions.")
            return
        }
        
        renderer.stem.register(PaginatorTag())
    }
    
    init(config: Config) throws {}
    func afterInit(_ drop: Droplet) {}
    func beforeRun(_: Droplet) {}
}
