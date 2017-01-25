import Vapor

public final class PaginatorProvider: Provider {
    public var provided: Providable = Providable()
    
    public func boot(_ drop: Droplet) {
        guard let renderer = drop.view as? LeafRenderer else {
            print("warning: you are not using Leaf, cannot register Paginator extensions.")
            return
        }
        
        renderer.stem.register(PaginatorTag(useBootstrap4: useBootstrap4, paginationLabel: paginationLabel))
    }
    
    fileprivate let useBootstrap4: Bool
    fileprivate let paginationLabel: String?
    
    public init(useBootstrap4: Bool = false, paginationLabel: String? = nil) {
        self.useBootstrap4 = useBootstrap4
        self.paginationLabel = paginationLabel
    }
    public init(config: Config) throws {
        // TODO
        useBootstrap4 = false
        paginationLabel = nil
    }
    public func afterInit(_ drop: Droplet) {}
    public func beforeRun(_: Droplet) {}
}
