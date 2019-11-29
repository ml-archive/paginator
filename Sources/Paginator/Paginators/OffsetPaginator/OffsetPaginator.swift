import Vapor

public struct OffsetPaginator<Object: Codable>: Content {
    public typealias PaginatorMetadata = OffsetMetadata

    public let data: [Object]
    public let metadata: OffsetMetadata

    public init(data: [Object], metadata: OffsetMetadata) {
        self.data = data
        self.metadata = metadata
    }
}

public extension OffsetPaginator {
    typealias ResultObject = Object
    typealias PaginatableMetadata = OffsetMetadata
}

public enum OffsetMetadataError: Error {
    case invalidParameters
}

public struct OffsetMetadata: Codable {
    struct Links: Codable {
        let previous: String?
        let next: String?
    }

    internal let url: URL
    public let currentPage: Int
    public let perPage: Int
    public let total: Int
    public let totalPages: Int
    let links: Links

    @available(*, deprecated, message: "use init(currentPage:perPage:total:url:)")
    public init(currentPage: Int, perPage: Int, total: Int, on req: Request) throws {
        try self.init(currentPage: currentPage, perPage: perPage, total: total, url: req.http.url)
    }

    public init(currentPage: Int, perPage: Int, total: Int, url: URL) throws {
        self.url = url
        self.currentPage = currentPage
        self.perPage = perPage
        self.total = total

        if perPage == 0 {
            
            if total == 0 {
                self.totalPages = 0
            } else {
                throw OffsetMetadataError.invalidParameters
            }
            
        } else {
            self.totalPages = max(1, Int(ceil(Double(total) / Double(perPage))))
        }

        let nav = try OffsetMetadata.nextAndPreviousLinks(
            currentPage: currentPage,
            totalPages: totalPages,
            url: url
        )
        self.links = Links(previous: nav.previous, next: nav.next)
    }
}

public struct OffsetQueryParameters: Decodable, Reflectable {
    public let perPage: Int?
    public let page: Int?

    static public func decode(req: Request) throws -> Future<OffsetQueryParameters> {
        let params = try req.query.decode(OffsetQueryParameters.self)
        return req.future(params)
    }
}

public struct OffsetParameters {
    public let perPage: Int
    public let page: Int

    init(queryParameters: OffsetQueryParameters, config: OffsetPaginatorConfig) {
        self.perPage = queryParameters.perPage ?? config.perPage
        self.page = queryParameters.page ?? config.defaultPage
    }
}

extension OffsetParameters {
    public var range: Range<Int> {
        let lower = (page - 1) * perPage
        return lower..<(lower + perPage)
    }
}
