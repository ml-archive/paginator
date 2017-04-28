import URI
import HTTP
import Core
import Vapor
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
    public func makeNode(in context: Context?) throws -> Node {
        var node = Node.object([:])

        var paginator = Node.object([:])
        try paginator.set("total", total)
        try paginator.set("per_page", perPage)
        try paginator.set("current_page", currentPage)
        try paginator.set("total_pages", totalPages)

        var links = Node.object([:])
        try links.set("previous", previousPage)
        try links.set("next", nextPage)

        try paginator.set("links", links)

        var meta = Node.object([:])
        try meta.set(paginatorName, paginator)

        try node.set("meta", meta)
        try node.set(dataKey, transform?(data ?? []) ?? data?.makeNode(in: nil))

        return node
    }
}

extension Node {
    func formEncode() -> String? {
        guard let dict: [String: StructuredData] = self.wrapped.object else {
            return nil
        }

        return dict.map {
            [$0.key, $0.value.string ?? ""].joined(separator: "=")
        }.joined(separator: "&")
    }
}

extension Request {
    public func addingValues(_ queries: [String : String]) throws -> Request {
        var newQueries = query?.object ?? [:]

        queries.forEach {
            newQueries[$0.key] = $0.value.makeNode(in: nil)
        }

        query = try newQueries.makeNode(in: nil)
        return self
    }
}
