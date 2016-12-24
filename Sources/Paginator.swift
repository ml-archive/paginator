import HTTP
import Vapor
import Fluent

public enum Error: Swift.Error {
    case `internal`
    case nilQuery
}

public struct Paginator<E: Entity> {
    public var total: Int?
    public var perPage: Int?
    public var currentPage: Int?
    public var totalPages: Int?
    public var links: [String]?
    
    public var data: Node?
    
    var query: Query<E>?
    
    init(query: Query<E>, pageName: String? = nil, request: Request) throws {
        self.query = query
        self.data = try extractQueryNode()
    }
    
    init?(perPage: Int, pageName: String? = nil, request: Request) {
        guard let query = request.query else { return nil }
        deserialize(node: query, pageName: pageName)
        self.perPage = perPage
        
        do {
            self.query = try E.query()
        } catch { return nil }
    }
}

extension Paginator {
    mutating func deserialize(node: Node, pageName: String?) {
        currentPage = node[pageName ?? "page"]?.int
        total = node["total"]?.int
        
    }
    
    mutating func extractQueryNode() throws -> Node {
        guard let query = query else {
            throw Error.nilQuery
        }
        
        //FIXME: Better caching system
        total = try total ?? query.getTotalCount()
        
        if let count = perPage {
            let limit = Limit(count: count, offset: (currentPage ?? 0) * count)
            query.limit = limit
        }
        
        return try query.raw()
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

extension Query {
    func getTotalCount() throws -> Int {
        //since this doesn't init the objects it _should_ be faster
        guard case .array(let array) = try raw() else {
            throw Error.internal
        }
        
        return array.count
    }
}
