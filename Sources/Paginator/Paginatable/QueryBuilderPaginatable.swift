import Fluent
import Vapor

public protocol QueryBuilderPaginatable: Paginatable {
    associatedtype PaginatableMetaData

    static func paginate<D: Database, Result>(
        query: QueryBuilder<D, Result>,
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
        return try self.paginate(count: self.count(), for: req)
    }

    public func paginate<P: Paginator>(
        count: Future<Int>,
        for req: Request
    ) throws -> Future<P> where
        P: QueryBuilderPaginatable,
        P.Object == Result,
        P.PaginatorMetaData == P.PaginatableMetaData
    {
        return try P.paginate(query: self, count: self.count(), on: req).map { args -> P in
            let (results, data) = args
            return try P.init(data: results, meta: data)
        }
    }
}

extension QueryBuilder: Transformable {
    public typealias TransformableQuery = QueryBuilder<Database, Result>
    public typealias TransformableQueryResult = Result

    public func transform<T: Codable>(
        on req: Request,
        _ transform: @escaping (TransformableQueryResult) throws -> T
    ) throws -> TransformingQuery<TransformableQuery, TransformableQueryResult, T> {
        let newTransform: (TransformableQueryResult) throws -> Future<T> = { result in
            return try req.future(transform(result))
        }

        return self.transform(on: req, newTransform)
    }

    func transform<T: Codable>(
        on req: Request,
        _ transform: @escaping (TransformableQueryResult) throws -> Future<T>
    ) -> TransformingQuery<TransformableQuery, TransformableQueryResult, T> {
        return TransformingQuery(query: self, transform: transform)
    }
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
        return try self.paginate(count: self.query.count(), for: req)
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
        return try P.paginate(
            query: self.query,
            count: self.query.count(),
            on: req
        ).flatMap { args -> Future<P> in
            let (results, data) = args
            return try results.map(self.transform).flatten(on: req).map { results in
                return try P.init(data: results, meta: data)
            }
        }
    }
}
