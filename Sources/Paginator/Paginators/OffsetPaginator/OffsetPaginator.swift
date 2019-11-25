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

    public init(currentPage: Int, perPage: Int, total: Int, on req: Request) throws {
        self.url = req.http.url
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

extension OffsetPaginator {
    public static func offsetMetaData<T>(
        count: Int,
        on req: Request,
        closure: @escaping (OffsetMetaData) -> Future<T>
    ) -> Future<(T, OffsetMetaData)> {
        return .flatMap(on: req) {
            try OffsetQueryParams.decode(req: req)
                .flatMap { params in
                    let config: OffsetPaginatorConfig = (try? req.make()) ?? .default

                    let page = params.page ?? config.defaultPage
                    let perPage = params.perPage ?? config.perPage

                    let metadata = try OffsetMetaData(
                        currentPage: page,
                        perPage: perPage,
                        total: count,
                        on: req
                    )
                    return closure(metadata).map { ($0, metadata) }
                }
        }
    }
}

extension OffsetMetaData {
    public var lower: Int {
        return (currentPage - 1) * perPage
    }

    public var upper: Int {
        return min((lower + perPage), total) - 1
    }
}
