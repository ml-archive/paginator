import Vapor

public struct OffsetPaginator<Object: Codable> {
    public typealias PaginatorMetaData = OffsetMetaData

    public let data: [Object]
    public let offsetMetaData: OffsetMetaData

    public init(data: [Object], offsetMetaData: OffsetMetaData) {
        self.data = data
        self.offsetMetaData = offsetMetaData
    }
}

public extension OffsetPaginator {
    typealias ResultObject = Object
    typealias PaginatableMetaData = OffsetMetaData
}

public enum OffsetMetaDataError: Error {
    case invalidParameters
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
                throw OffsetMetaDataError.invalidParameters
            }
            
        } else {
            self.totalPages = max(1, Int(ceil(Double(total) / Double(perPage))))
        }

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

extension OffsetMetaData {
    public var range: Range<Int> {
        let lower = (currentPage - 1) * perPage
        return lower..<min(lower + perPage, total)
    }
}
