import Vapor

public final class PaginatorProvider: Provider {
    public var provided: Providable = Providable()
    
    public func boot(_ drop: Droplet) {
        guard let renderer = drop.view as? LeafRenderer else {
            print("warning: you are not using Leaf, cannot register Paginator extensions.")
            return
        }
        
        renderer.stem.register(PaginatorTag())
    }
    
    public init(config: Config) throws {}
    public func afterInit(_ drop: Droplet) {}
    public func beforeRun(_: Droplet) {}
}
