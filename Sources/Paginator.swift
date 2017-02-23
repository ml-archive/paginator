import URI
import HTTP
import Core
import Vapor
import Fluent

public class Paginator<EntityType: Entity> {
    public var currentPage: Int
    public var perPage: Int
    
    public var total: Int?
    
    public var baseURI: URI
    public var uriQueries: Node?
    
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
    
    public var data: [EntityType]?
    
    var query: Query<EntityType>
    var transform: (([EntityType]) throws -> Node)?
    
    init(
        query: Query<EntityType>,
        currentPage: Int = 1,
        perPage: Int,
        pageName: String,
        dataKey: String,
        transform: (([EntityType]) throws -> Node)?,
        request: Request
    ) throws {
        self.query = query
        self.currentPage = currentPage
        self.perPage = perPage
        self.pageName = pageName
        self.dataKey = dataKey
        self.transform = transform

        baseURI = request.uri
        uriQueries = request.query

        self.data = try extractEntityData()
    }
    
    public init(
        _ entities: [EntityType],
        page currentPage: Int = 1,
        perPage: Int,
        pageName: String = "page",
        dataKey: String = "data",
        request: Request
    ) throws {
        query = try EntityType.query()
        self.currentPage = currentPage
        self.perPage = perPage
        self.pageName = pageName
        self.dataKey = dataKey
        
        baseURI = request.uri
        uriQueries = request.query
        total = entities.count
        data = entities
        transform = nil
    }
}

extension Paginator {
    func extractEntityData() throws -> [EntityType] {
        //FIXME(Brett): Better caching system
        total = try total ?? query.run().count

        if let page = uriQueries?[pageName]?.int {
            currentPage = page
        }

        if let count = uriQueries?["count"]?.int, count < perPage {
            perPage = count
        }

        let offset = (currentPage - 1) * perPage
        let limit = Limit(count: perPage, offset: offset)
        query.limit = limit

        return try query.run()
    }
}

extension Paginator {
    func buildPath(page: Int, count: Int) -> String? {
        var urlQueriesRaw = uriQueries ?? [:]
        urlQueriesRaw[pageName] = .number(.int(page))
        urlQueriesRaw["count"] = .number(.int(count))
        
        guard let urlQueries = urlQueriesRaw.formEncode() else { return nil }
        
        return [
            baseURI.path,
            "?",
            urlQueries
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
            
            dataKey: transform?(data ?? []) ?? data?.makeNode(context: context)
        ])
    }
}

extension Node {
    func formEncode() -> String? {
        guard case .object(let dict) = self else {
            return nil
        }
        
        return dict.map {
            [$0.key, $0.value.string ?? ""].joined(separator: "=")
        }.joined(separator: "&")
    }
}

extension Request {
    public func addingValues(_ queries: [String : String]) throws -> Request {
        var newQueries = query?.nodeObject ?? [:]
        
        queries.forEach {
            newQueries[$0.key] = $0.value.makeNode()
        }
        
        query = try newQueries.makeNode()
        return self
    }
}
