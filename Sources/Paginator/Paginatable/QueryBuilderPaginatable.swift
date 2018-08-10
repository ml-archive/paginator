import Fluent
import Vapor

public protocol QueryBuilderPaginatable {
    associatedtype PaginatableMetaData

    static func paginate<D: Database, Result>(
        count: Future<Int>,
        query: QueryBuilder<D, Result>,
        on req: Request
    ) throws -> Future<([Result], PaginatableMetaData)>
}

extension QueryBuilderPaginatable {
    public static func paginate<D: Database, Result>(
        query: QueryBuilder<D, Result>,
        on req: Request
    ) throws -> Future<([Result], PaginatableMetaData)> {
        return try paginate(count: query.count(), query: query, on: req)
    }
}

public extension QueryBuilder {
    public func paginate<P: Paginator>(
        for req: Request
    ) throws -> Future<P> where
        P: QueryBuilderPaginatable,
        P.Object == Result,
        P.PaginatorMetaData == P.PaginatableMetaData
    {
        return try P.paginate(query: self, on: req).map { args -> P in
            let (results, data) = args
            return try P.init(data: results, meta: data)
        }
    }
}
