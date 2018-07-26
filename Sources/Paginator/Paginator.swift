import Fluent
import Sugar
import Vapor

// MARK: Config

public struct OffsetPaginatorConfig: Service {
    public let perPage: Int
    public let page: Int

    public init(perPage: Int, page: Int) {
        self.perPage = perPage
        self.page = page
    }
}

// MARK: Paginator

public protocol PaginatorType: Content {
    associatedtype Data: Codable
    associatedtype PaginationMeta

    init(data: [Data], paginationMeta: PaginationMeta?)

    var data: [Data]? { get }
    var paginationMeta: PaginationMeta? { get }
}

// MARK: Paginatable

public protocol Paginatable: Codable {
    associatedtype Q
    associatedtype C
    associatedtype R

    static func paginate(
        query: Q,
        on req: Request
    ) throws -> Future<([C], R)>
}

// MARK: Convenience for transformation

public extension Future where T: PaginatorType {
    public func transform<C: PaginatorType>(
        transform: @escaping ([T.Data]) -> [C.Data]
    ) -> Future<C> where T.PaginationMeta == C.PaginationMeta {
        return self.map { paginator in
            let transformed = paginator.data.map { transform($0) }
            return C.init(data: transformed ?? [], paginationMeta: paginator.paginationMeta)
        }
    }

    public func transform<C: PaginatorType>(
        transform: @escaping ([T.Data]) throws -> Future<[C.Data]>
    ) -> Future<C> where T.PaginationMeta == C.PaginationMeta {
        return self
            .flatMap { paginator in
                try transform(paginator.data ?? [])
                    .map { C.init(data: $0, paginationMeta: paginator.paginationMeta) }
            }
    }

    public func transform<C: PaginatorType>(
        transform: @escaping (T.Data) -> C.Data
    ) -> Future<C> where T.PaginationMeta == C.PaginationMeta {
        return self.map { paginator in
            let transformed = paginator.data?.map { transform($0) }
            return C.init(data: transformed ?? [], paginationMeta: paginator.paginationMeta)
        }
    }

    public func transform<C: PaginatorType>(
        transform: @escaping (T.Data) throws -> Future<C.Data>, on req: Request
    ) -> Future<C> where T.PaginationMeta == C.PaginationMeta {
        return self.flatMap { paginator in
            let transformed = try paginator.data?
                .map { try transform($0) }
                .flatten(on: req)
                ?? Future.transform(to: [], on: req)

            return transformed.map {
                C.init(data: $0, paginationMeta: paginator.paginationMeta)
            }
        }
    }
}

// MARK: Pagination convenience for querybuilder

public extension QueryBuilder where Result: Model, Result.Database == Database {
    public func paginate<P: PaginatorType>(
        for req: Request
    ) throws -> Future<P> where
        P: PaginatableByModel,
        P.Data == Result,
//        P.Q == QueryBuilder<Result.Database, Result>,
        P.C == Result,
        P.PaginationMeta == P.R
    {
        return try P.paginate(query: self, on: req).map { args -> P in
            let (results, data) = args
            return P.init(data: results, paginationMeta: data)
        }
    }
}

// MARK: Pagination convenience for lists

public extension Array where Iterator.Element: Codable {
    public func paginate<P: PaginatorType>(
        for req: Request
    ) throws -> Future<P> where
        P: PaginatableByCodable,
        P.Data == Iterator.Element,
        P.C == Iterator.Element,
        P.PaginationMeta == P.R
    {
        return try P.paginate(query: self, on: req).map { args -> P in
            let (results, data) = args
            return P.init(data: results, paginationMeta: data)
        }
    }
}



// MARK: OffsetPaginator

public struct OffsetData {
    let currentPage: Int
    let perPage: Int
    let total: Int
    let previousLink: String?
    let nextLink: String?
}

public struct OffsetPaginator<Data: Codable>: PaginatorType {
    public typealias PaginationMeta = OffsetData

    struct Meta: Codable {
        struct Links: Codable {
            let next: String?
            let previous: String?
        }

        let currentPage: Int
        let perPage: Int
        let total: Int
        let totalPages: Int
        let links: Links
    }

    public let data: [Data]?
    public var paginationMeta: OffsetData? = nil
    let meta: Meta

    public init(data: [Data], paginationMeta: OffsetData?) {
        self.data = data
        self.paginationMeta = paginationMeta

        self.meta = Meta(
            currentPage: paginationMeta?.currentPage ?? 0,
            perPage: paginationMeta?.perPage ?? 0,
            total: paginationMeta?.total ?? 0,
            totalPages: Int(ceil(Double(paginationMeta!.total) / Double(paginationMeta!.perPage))),
            links: Meta.Links(
                next: paginationMeta?.nextLink,
                previous: paginationMeta?.previousLink
            )
        )
    }

    private enum CodingKeys: String, CodingKey {
        case data
        case meta
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

public protocol PaginatableByModel {
    associatedtype C: Model
    associatedtype R

    static func paginate(
        query: QueryBuilder<C.Database, C>,
        on req: Request
    ) throws -> Future<([C], R)>
}

public protocol PaginatableByCodable {
    associatedtype C: Codable
    associatedtype R

    static func paginate(
        query: [C],
        on req: Request
    ) throws -> Future<([C], R)>
}

public extension OffsetPaginator {
    public typealias C = Data
    public typealias R = OffsetData
}

extension OffsetPaginator: PaginatableByCodable {
    public static func paginate(
        query: [Data],
        on req: Request
    ) throws -> EventLoopFuture<([Data], OffsetData)> {
        let config: OffsetPaginatorConfig = try req.make()
        return try OffsetQueryParams.decode(req: req)
            .map { params in
                let count = query.count
                let perPage = params.perPage ?? config.perPage
                let totalPages = Int(ceil(Double(count) / Double(perPage)))

                let page = params.page ?? config.page
                let lower = (page - 1) * perPage
                var upper = (lower + perPage) - 1

                if upper >= count {
                    upper = count - 1
                }

                let nav = try links(currentPage: page, totalPages: totalPages, on: req)
                let data = OffsetData(
                    currentPage: page,
                    perPage: perPage,
                    total: count,
                    previousLink: nav.0,
                    nextLink: nav.1
                )

                guard page <= totalPages && page > 0 else {
                    return ([], data)
                }

                return (Array(query[lower...upper]), data)
            }
    }
}

extension OffsetPaginator: PaginatableByModel where Data: Model {
    public static func paginate(
        query: QueryBuilder<Data.Database, Data>,
        on req: Request
    ) throws -> Future<([Data], OffsetData)> {
        let config: OffsetPaginatorConfig = try req.make()
        return try OffsetQueryParams.decode(req: req)
            .flatMap { params in
                let page = params.page ?? config.page
                let perPage = params.perPage ?? config.perPage
                let lower = (page - 1) * perPage
                let upper = (lower + perPage) - 1

                return C.query(on: req).count()
                    .flatMap { count in
                        let totalPages = Int(ceil(Double(count) / Double(perPage)))
                        let nav = try links(currentPage: page, totalPages: totalPages, on: req)
                        let data = OffsetData(
                            currentPage: page,
                            perPage: perPage,
                            total: count,
                            previousLink: nav.0,
                            nextLink: nav.1
                        )
                        return query.range(lower: lower, upper: upper).all()
                            .map { ($0, data) }
                    }
            }
    }
}

private extension OffsetPaginator {
    private static func links(currentPage: Int, totalPages: Int, on req: Request) throws -> (String?, String?) {
        func link(url: URL, page: Int) throws -> String {
            guard
                let pageName = try OffsetQueryParams.reflectProperty(forKey: \.page)?.path.last,
                var components = URLComponents(url: req.http.url, resolvingAgainstBaseURL: false)
            else {
                throw Abort.init(.internalServerError)
            }

            var queryItems = components.queryItems?.filter { $0.name != pageName } ?? []
            queryItems.append(URLQueryItem(name: pageName, value: String(page)))
            components.queryItems = queryItems

            guard let url = components.url?.absoluteString else {
                throw Abort.init(.internalServerError)
            }

            return url
        }

        var previous: String? = nil
        var next: String? = nil

        if currentPage > 1 {
            let previousPage = (currentPage <= totalPages) ? currentPage - 1 : totalPages
            previous = try link(url: req.http.url, page: previousPage)
        }

        if currentPage < totalPages {
            next = try link(url: req.http.url, page: currentPage + 1)
        }

        return (previous, next)
    }
}
