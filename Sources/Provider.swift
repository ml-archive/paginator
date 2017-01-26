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
    
    /**
        Creates a Paginator provider from a `paginator.json` config file. Both the config file
        and the options are optional, and it will default to Bootstrap 3 with no Aria Label if
        none supplied
     
         The file may contain similar JSON:
         
         {
            "useBootstrap4": true,
            "paginatorLabel": "Blog Post Pages"
         }
     */
    public init(config: Config) throws {
        
        var useBootstrap4Value = false
        var paginatorLabelValue: String? = nil
        
        
        if let paginatorConfig = config["paginator"]?.object {
            paginatorLabelValue = paginatorConfig["paginatorLabel"]?.string
            if let bootstrap4 = paginatorConfig["useBootstrap4"]?.bool {
                useBootstrap4Value = bootstrap4
            }
        }
        
        useBootstrap4 = useBootstrap4Value
        paginationLabel = paginatorLabelValue
    }
    public func afterInit(_ drop: Droplet) {}
    public func beforeRun(_: Droplet) {}
}
