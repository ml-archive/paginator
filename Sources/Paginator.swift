import URI
import HTTP
import Core
import Vapor
import Fluent
import FluentProvider

public class Paginator<EntityType: Entity> where EntityType: NodeConvertible {
    public var currentPage: Int
    public var perPage: Int

    public var total: Int?

    public var baseURI: URI
    public var uriQueries: Node?

    public var paginatorName: String
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

        return PaginatorHelper.buildPath(
            baseURI: baseURI.path,
            page: previous,
            count: perPage,
            uriQueries: uriQueries,
            pageName: pageName
        )
    }

    public var nextPage: String? {
        guard let totalPages = totalPages else { return nil }
        let next = currentPage + 1
        guard next <= totalPages else { return nil }

        return PaginatorHelper.buildPath(
            baseURI: baseURI.path,
            page: next,
            count: perPage,
            uriQueries: uriQueries,
            pageName: pageName
        )
    }

    public var data: [EntityType]?

    var query: Query<EntityType>
    var transform: (([EntityType]) throws -> Node)?

    init(
        query: Query<EntityType>,
        currentPage: Int = 1,
        perPage: Int,
        paginatorName: String,
        pageName: String,
        dataKey: String,
        transform: (([EntityType]) throws -> Node)?,
        request: Request
    ) throws {
        self.query = query
        self.currentPage = currentPage
        self.perPage = perPage
        self.paginatorName = paginatorName
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
        paginatorName: String = "paginator",
        pageName: String = "page",
        dataKey: String = "data",
        request: Request
    ) throws {
        query = try EntityType.makeQuery()
        self.currentPage = currentPage
        self.perPage = perPage
        self.paginatorName = paginatorName
        self.pageName = pageName
        self.dataKey = dataKey

        baseURI = request.uri
        uriQueries = request.query
        total = entities.count
        data = extractSequenceData(from: entities)
        transform = nil
    }
}

extension Paginator {
    func extractEntityData() throws -> [EntityType] {
        //FIXME(Brett): Better caching system
        total = try total ?? query.count()

        if let page = uriQueries?[pageName]?.int {
            currentPage = page
        }

        if let count = uriQueries?["count"]?.int, count < perPage {
            perPage = count
        }

        let offset = (currentPage - 1) * perPage
        let limit = Limit(count: perPage, offset: offset)
        query.limits.append(RawOr.some(limit))

        return try query.all()
    }

    func extractSequenceData(from data: [EntityType]?) -> [EntityType] {
        guard let sequenceData = data else {
            return []
        }

        var pageData = sequenceData

        if pageData.count > 0 {
            if let page = uriQueries?[pageName]?.int {
                currentPage = page
            }

            if let count = uriQueries?["count"]?.int, count < perPage {
                perPage = count
            }

            var position = (((currentPage - 1) * perPage) + perPage) - 1

            let offset = perPage * (currentPage - 1)

            if offset > pageData.count {
                return []
            }

            if position >= pageData.count {
                position = pageData.count - 1
            }

            pageData = Array(pageData[offset...position])
        }

        return pageData
    }
}

enum Keys {
    case perPage
    case currentPage
    case totalPages
    case queries

    internal var key: String {
        let convention = Database.default?.keyNamingConvention ?? .camelCase

        switch self {
        case .perPage:
            return convention == .camelCase ? "perPage" : "per_page"

        case .currentPage:
            return convention == .camelCase ? "currentPage" : "current_page"

        case .totalPages:
            return convention == .camelCase ? "totalPages" : "total_pages"
        case .queries:
            return "queries"
        }
    }

}

extension Paginator: NodeRepresentable {
    public func makeNode(in context: Context?) throws -> Node {
        var node = Node.object([:])

        var paginator = Node.object([:])
        try paginator.set("total", total)
        try paginator.set(Keys.perPage.key, perPage)
        try paginator.set(Keys.currentPage.key, currentPage)
        try paginator.set(Keys.totalPages.key, totalPages)
        try paginator.set(Keys.queries.key, uriQueries)

        var links = Node.object([:])
        try links.set("previous", previousPage)
        try links.set("next", nextPage)

        try paginator.set("links", links)

        var meta = Node.object([:])
        try meta.set(paginatorName, paginator)

        try node.set("meta", meta)
        try node.set(dataKey, transform?(data ?? []) ?? data?.makeNode(in: context))

        return node
    }
}

extension Node {
    func formEncode() -> String? {
        guard let dict: [String: StructuredData] = self.wrapped.object else {
            return nil
        }

        let result = dict.flatMap { key, value -> [String] in
            if let valueArray = value.array {
                return valueArray.map{ [key, $0.string?.wwwFormUrlEncoded() ?? ""].joined(separator: "=") }
            } else {
                return [[key,value.string?.wwwFormUrlEncoded() ?? ""].joined(separator: "=")]
            }
         }

        return result.joined(separator: "&")
    }
}

extension String {
    func wwwFormUrlEncoded()->String {
        
        guard (self != "") else { return self }
        
        var newStr = self
        
        let entities = [
            " "    : "+",
            "&"     : "%26"
        ]
        
        for (character,value) in entities {
            newStr = newStr.replacingOccurrences(of: character, with: value)
        }
        
        return newStr
    }
}