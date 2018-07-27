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
    public typealias ResultObject = Object
    public typealias PaginatableMetaData = OffsetMetaData
}

public struct OffsetMetaData: Codable {
    struct Links: Codable {
        let previous: String?
        let next: String?
    }

    let currentPage: Int
    let perPage: Int
    let total: Int
    let totalPages: Int
    let links: Links

    init(currentPage: Int, perPage: Int, total: Int, on req: Request) throws {
        self.currentPage = currentPage
        self.perPage = perPage
        self.total = total
        self.totalPages = Int(ceil(Double(total) / Double(perPage)))
        let nav = try OffsetMetaData.links(
            currentPage: currentPage,
            totalPages: totalPages,
            on: req
        )
        self.links = Links(previous: nav.previous, next: nav.next)
    }
}

public struct OffsetQueryParams: Decodable, Reflectable {
    let perPage: Int?
    let page: Int?

    static public func decode(req: Request) throws -> Future<OffsetQueryParams> {
        let params = try req.query.decode(OffsetQueryParams.self)
        return Future.transform(to: params, on: req)
    }
}
