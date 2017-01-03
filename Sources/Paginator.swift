import HTTP
import Vapor
import Fluent

public enum Error: Swift.Error {
    case `internal`
    case nilQuery
}

public struct Paginator<EntityType: Entity> {
    public var total: Int?
    public var perPage: Int?
    public var currentPage: Int?
    public var links: [String]?
    
    public var totalPages: Int? {
        guard let total = total, let perPage = perPage else {
            return nil
        }
        
        var pages = total / perPage
        if total % perPage != 0 {
            pages += 1
        }
        
        return pages
    }
    
    public var previousPage: String? {
        return nil
    }
    
    public var nextPage: String? {
        return nil
    }
    
    public var data: Node?
    
    var query: Query<EntityType>?
    
    init(query: Query<EntityType>, pageName: String? = nil, request: Request) throws {
        self.query = query
        self.data = try extractQueryNode()
    }
    
    init(perPage: Int, pageName: String? = nil, request: Request) throws {
        if let query = request.query {
            deserialize(node: query, pageName: pageName)
        }
        
        self.perPage = perPage
        
        self.query = try EntityType.query()
        self.data = try extractQueryNode()
    }
}

extension Paginator {
    mutating func deserialize(node: Node, pageName: String?) {
        currentPage = node[pageName ?? "page"]?.int ?? 0
        total = node["total"]?.int
    }
    
    mutating func extractQueryNode() throws -> Node {
        guard let query = query else {
            throw Error.nilQuery
        }
        
        if let count = perPage {
            let current = currentPage ?? 0
            let offset = (current - 1) * count
            let limit = Limit(count: count, offset: offset)
            query.limit = limit
        }
        
        let node = try query.raw()
        //FIXME: Better caching system
        total = try total ?? query.count()
        
        return node
    }
}

extension Paginator: NodeRepresentable, JSONRepresentable, ResponseRepresentable {
    public func makeResponse() throws -> Response {
        return try makeJSON().makeResponse()
    }
    
    public func makeJSON() throws -> JSON {
        let node = try makeNode()
        return try JSON(node: node)
    }
    
    public func makeNode(context: Context) throws -> Node {
        guard let data = data else {
            throw Error.internal
        }
        
        let node =  try Node(node: [
            "total": total,
            "per_page": perPage,
            "current_page": currentPage,
            "total_pages": totalPages,
            "links": links?.makeNode(),
            
            "data": data
        ])
        
        return node
    }
}
