import Fluent
import Vapor

public protocol QueryBuilderPaginatable {
    associatedtype ResultObject: Model
    associatedtype PaginatableMetaData

    static func paginate(
        query: QueryBuilder<ResultObject.Database, ResultObject>,
        on req: Request
    ) throws -> Future<([ResultObject], PaginatableMetaData)>
}

public extension QueryBuilder where Result: Model, Result.Database == Database {
    public func paginate<P: Paginator>(
        for req: Request
    ) throws -> Future<P> where
        P: QueryBuilderPaginatable,
        P.Object == Result,
        P.ResultObject == Result,
        P.PaginatorMetaData == P.PaginatableMetaData
    {
        return try P.paginate(query: self, on: req).map { args -> P in
            let (results, data) = args
            return try P.init(data: results, meta: data)
        }
    }
}
