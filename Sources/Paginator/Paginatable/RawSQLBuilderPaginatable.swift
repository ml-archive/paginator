import Fluent
import Vapor
import SQL

protocol RawSQLBuilderPaginatable: Paginatable {
    associatedtype PaginatableMetaData
    
    static func paginate<D: Database, Result>(
        source: RawSQLBuilder<D, Result>,
        count: Future<Int>,
        on req: Request
    ) throws -> Future<([Result], PaginatableMetaData)>
}

class RawSQLBuilder<Database, Result> where
    Database: DatabaseKit.Database,
    Database.Connection: SQLConnectable,
    Result: Decodable
{
    let sqlRawBuilder: SQLRawBuilder<Database.Connection>
    let sqlRawCountBuilder: SQLRawBuilder<Database.Connection>?
    
    struct CountResult: Codable {
        let count: Int
    }
    
    init(query: String, countQuery: String?, connection: Database.Connection) {
        self.sqlRawBuilder = connection.raw(query)
        
        guard let countQuery = countQuery else {
            self.sqlRawCountBuilder = nil
            return
        }
        
        self.sqlRawCountBuilder = connection.raw(countQuery)
    }
}

extension RawSQLBuilder {
    func count(for req: Request) throws -> EventLoopFuture<Int> {
        guard let sqlRawCountBuilder = sqlRawCountBuilder else {
            throw Abort(HTTPStatus.internalServerError, reason: "Cannot compute count")
        }
        
        return sqlRawCountBuilder.all(decoding: CountResult.self).map({ output in
            return output.first?.count ?? 0
        })
    }
    
    func paginate<P: Paginator>(
        for req: Request
    ) throws -> Future<P> where
        P: RawSQLBuilderPaginatable,
        P.Object == Result,
        P.PaginatorMetaData == P.PaginatableMetaData
    {
        return try self.paginate(count: self.count(for: req), for: req)
    }
    
    func paginate<P: Paginator>(
        count: Future<Int>,
        for req: Request
    ) throws -> Future<P> where
        P: RawSQLBuilderPaginatable,
        P.Object == Result,
        P.PaginatorMetaData == P.PaginatableMetaData
    {
        return try P.paginate(source: self, count: count, on: req).map { args -> P in
            let (results, data) = args
            return try P(data: results, meta: data)
        }
    }
}

extension RawSQLBuilder: Transformable {
    typealias TransformableQuery = RawSQLBuilder<Database, Result>
    typealias TransformableQueryResult = Result
}

extension TransformingQuery {
    func paginate<P: Paginator, Database>(
        for req: Request
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
        for req: Request
    ) throws -> Future<P> where
        P: RawSQLBuilderPaginatable,
        Query: RawSQLBuilder<Database, Result>,
        TransformedResult == P.Object,
        P.PaginatorMetaData == P.PaginatableMetaData
    {
        return try P
            .paginate(source: self.source, count: count, on: req)
            .flatMap { args -> Future<P> in
                let (results, data) = args
                return try self.transform(results).map { results in
                    return try P(data: results, meta: data)
                }
        }
    }
}
