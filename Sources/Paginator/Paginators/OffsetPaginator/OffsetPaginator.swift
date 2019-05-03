import Vapor

public struct OffsetPaginator<Object: Codable>: Paginator {
    public typealias PaginatorMetaData = OffsetMetaData

    public let data: [Object]?
    let meta: OffsetMetaData

    public init(data: [Object], meta: OffsetMetaData?) throws {
        guard let meta = meta else {
            throw Abort(
                .internalServerError,
                reason: "Expected meta data for paginator was not provided."
            )
        }

        self.data = data
        self.meta = meta
    }

    public func metaData() -> OffsetMetaData? {
        return meta
    }
}

public extension OffsetPaginator {
    typealias ResultObject = Object
    typealias PaginatableMetaData = OffsetMetaData
}

public struct OffsetMetaData: Codable {
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

    public init(currentPage: Int, perPage: Int, total: Int, on req: Request) throws {
        self.url = req.http.url
        self.currentPage = currentPage
        self.perPage = perPage
        self.total = total
        self.totalPages = max(1, Int(ceil(Double(total) / Double(perPage))))
        let nav = try OffsetMetaData.nextAndPreviousLinks(
            currentPage: currentPage,
            totalPages: totalPages,
            url: url
        )
        self.links = Links(previous: nav.previous, next: nav.next)
    }
}

public struct OffsetQueryParams: Decodable, Reflectable {
    public let perPage: Int?
    public let page: Int?

    static public func decode(req: Request) throws -> Future<OffsetQueryParams> {
        let params = try req.query.decode(OffsetQueryParams.self)
        return req.future(params)
    }
}
