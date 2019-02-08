import Fluent
import Vapor

public protocol QueryBuilderPaginatable: Paginatable {
    associatedtype PaginatableMetaData

    static func paginate<D: Database, Result>(
        source: QueryBuilder<D, Result>,
        count: Future<Int>,
        on req: Request
    ) throws -> Future<([Result], PaginatableMetaData)>
}

public extension QueryBuilder {
    public func paginate<P: Paginator>(
        for req: Request
    ) throws -> Future<P> where
        P: QueryBuilderPaginatable,
        P.Object == Result,
        P.PaginatorMetaData == P.PaginatableMetaData
    {
        return try paginate(count: count(), for: req)
    }

    public func paginate<P: Paginator>(
        count: Future<Int>,
        for req: Request
    ) throws -> Future<P> where
        P: QueryBuilderPaginatable,
        P.Object == Result,
        P.PaginatorMetaData == P.PaginatableMetaData
    {
        return try P.paginate(source: self, count: count, on: req).map(P.init)
    }
}

extension QueryBuilder: Transformable {
    public typealias TransformableQuery = QueryBuilder<Database, Result>
    public typealias TransformableQueryResult = Result
}

public extension TransformingQuery {
    public func paginate<P: Paginator, T>(
        for req: Request
    ) throws -> Future<P> where
        T: QuerySupporting,
        P: QueryBuilderPaginatable,
        Query: QueryBuilder<T, Result>,
        TransformedResult == P.Object,
        P.PaginatorMetaData == P.PaginatableMetaData
    {
        return try self.paginate(count: self.source.count(), for: req)
    }

    public func paginate<P: Paginator, T>(
        count: Future<Int>,
        for req: Request
    ) throws -> Future<P> where
        T: QuerySupporting,
        P: QueryBuilderPaginatable,
        Query: QueryBuilder<T, Result>,
        TransformedResult == P.Object,
        P.PaginatorMetaData == P.PaginatableMetaData
    {
        return try P
            .paginate(source: self.source, count: count, on: req)
            .flatMap { (results, metadata) -> Future<P> in
                try self.transform(results).map { try P(data: $0, meta: metadata) }
            }
    }
}
