import URI
import HTTP
import Vapor
import Fluent

public struct Paginator<EntityType: Entity> {
    public var currentPage: Int
    public var perPage: Int
    
    public var total: Int?
    
    public var baseURI: URI
    
    public var pageName: String
    public var dataKey: String
    
    public var totalPages: Int? {
        guard let total = total else {
            return nil
        }
        
        var pages = total / perPage
        if total % perPage != 0 {
            pages += 1
        }
        
        return pages
    }
    
    public var previousPage: String? {
        let previous = currentPage - 1
        guard previous >= 1 else { return nil }
        
        return buildPath(page: previous, count: perPage)
    }
    
    public var nextPage: String? {
        guard let totalPages = totalPages else { return nil }
        let next = currentPage + 1
        guard next <= totalPages else { return nil }
        
        return buildPath(page: next, count: perPage)
    }
    
    public var data: Node?
    
    var query: Query<EntityType>
    
    init(
        query: Query<EntityType>,
        currentPage: Int = 1,
        perPage: Int,
        pageName: String,
        dataKey: String,
        request: Request
    ) throws {
        self.query = query
        self.currentPage = currentPage
        self.perPage = perPage
        self.pageName = pageName
        self.dataKey = dataKey
        
        baseURI = request.uri
        
        self.data = try extractEntityData(request.query)
    }
}

extension Paginator {
    mutating func extractEntityData(_ node: Node?) throws -> Node {
        if let page = node?[pageName]?.int {
            currentPage = page
        }
        
        if let count = node?["count"]?.int, count < perPage {
            perPage = count
        }
        
        let offset = (currentPage - 1) * perPage
        let limit = Limit(count: perPage, offset: offset)
        query.limit = limit
        
        //FIXME(Brett): Better caching system
        total = try EntityType.query().count()
        
        let node = try query.raw()
        
        return node
    }
}

extension Paginator {
    func buildPath(page: Int, count: Int) -> String {
        return [
            baseURI.path,
            "?",
            pageName,
            "=",
            "\(page)",
            "&count=",
            "\(count)"
            ].joined()
    }
}

extension Paginator: NodeRepresentable {
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "meta": Node(node: [
                "paginator": Node(node: [
                    "total": total,
                    "per_page": perPage,
                    "current_page": currentPage,
                    "total_pages": totalPages,
                    "links": Node(node: [
                        "previous": previousPage,
                        "next": nextPage
                    ]),
                ])
            ]),
            
            dataKey: data
        ])
    }
}
