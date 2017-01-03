import URI
import HTTP
import Vapor
import Fluent

public enum Error: Swift.Error {
    case `internal`
    case nilQuery
}

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
    mutating func deserialize(query node: Node) {
        if let currentPage = node[pageName]?.int {
            self.currentPage = currentPage
        }
        
        if let total = node["total"]?.int {
            self.total = total
        }
    }
    
    mutating func extractEntityData(_ node: Node?) throws -> Node {
        let page = node?[pageName]?.int ?? currentPage
        
        let offset = (page - 1) * perPage
        let limit = Limit(count: perPage, offset: offset)
        query.limit = limit
        
        //FIXME: Better caching system
        total = try total ?? EntityType.query().count()
        
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
        
        return node
    }
}
