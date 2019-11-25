import Fluent
import Vapor
import SQL

public protocol RawSQLBuilderPaginatable: Paginatable {
    associatedtype PaginatableMetaData
    
    static func paginate<D: Database, Result>(
        source: RawSQLBuilder<D, Result>,
        count: Future<Int>,
        on req: Request
    ) throws -> Future<([Result], PaginatableMetaData)>
}

public class RawSQLBuilder<Database, Result> where
    Database: DatabaseKit.Database,
    Database.Connection: SQLConnectable,
    Result: Decodable
{
    let sqlRawBuilder: SQLRawBuilder<Database.Connection>
    let sqlRawCountBuilder: SQLRawBuilder<Database.Connection>?
    
    struct CountResult: Codable {
        let count: Int
    }
    
    public init(query: String, countQuery: String?, connection: Database.Connection) {
        self.sqlRawBuilder = connection.raw(query)
        
        guard let countQuery = countQuery else {
            self.sqlRawCountBuilder = nil
            return
        }
        
        self.sqlRawCountBuilder = connection.raw(countQuery)
    }
    
    public func bind(_ encodable: Encodable) -> Self {
        _ = sqlRawBuilder.bind(encodable)
        _ = sqlRawCountBuilder?.bind(encodable)
        return self
    }
    
    public func binds(_ encodables: [Encodable]) -> Self {
        _ = sqlRawBuilder.binds(encodables)
        _ = sqlRawCountBuilder?.binds(encodables)
        return self
    }
}

public extension RawSQLBuilder {
    func count(for req: Request) throws -> EventLoopFuture<Int> {
        guard let sqlRawCountBuilder = sqlRawCountBuilder else {
            throw Abort(HTTPStatus.internalServerError, reason: "Cannot compute count")
        }
        
        return sqlRawCountBuilder.all(decoding: CountResult.self).map({ output in
            return output.first?.count ?? 0
        })
    }
    
    func paginate<P: Paginator>(
        for req: Request,
        type: P.Type = P.self
    ) throws -> Future<P> where
        P: RawSQLBuilderPaginatable,
        P.Object == Result,
        P.PaginatorMetaData == P.PaginatableMetaData
    {
        return try self.paginate(count: self.count(for: req), for: req)
    }
    
    func paginate<P: Paginator>(
        count: Future<Int>,
        for req: Request,
        type: P.Type = P.self
    ) throws -> Future<P> where
        P: RawSQLBuilderPaginatable,
        P.Object == Result,
        P.PaginatorMetaData == P.PaginatableMetaData
    {
        return try P.paginate(source: self, count: count, on: req).map { results, data -> P in
            try P(data: results, meta: data)
        }
    }
}

extension RawSQLBuilder: Transformable {
    public typealias TransformableQuery = RawSQLBuilder<Database, Result>
    public typealias TransformableQueryResult = Result
}

public extension TransformingQuery {
    func paginate<P: Paginator, Database>(
        for req: Request,
        type: P.Type = P.self
    ) throws -> Future<P> where
        P: RawSQLBuilderPaginatable,
        Query: RawSQLBuilder<Database, Result>,
        TransformedResult == P.Object,
        P.PaginatorMetaData == P.PaginatableMetaData
    {
        return try self.paginate(count: self.source.count(for: req), for: req)
    }
    
    func paginate<P: Paginator, Database>(
        count: Future<Int>,
        for req: Request,
        type: P.Type = P.self
    ) throws -> Future<P> where
        P: RawSQLBuilderPaginatable,
        Query: RawSQLBuilder<Database, Result>,
        TransformedResult == P.Object,
        P.PaginatorMetaData == P.PaginatableMetaData
    {
        return try P
            .paginate(source: self.source, count: count, on: req)
            .flatMap { results, data in
                try self.transform(results).map { results in
                    try P(data: results, meta: data)
                }
        }
    }
}
