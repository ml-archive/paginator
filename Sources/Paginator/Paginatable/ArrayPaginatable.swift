import Vapor

public protocol ArrayPaginatable: Paginatable {
    associatedtype PaginatableMetaData

    static func paginate<Object>(
        query: [Object],
        on req: Request
    ) throws -> Future<([Object], PaginatableMetaData)>
}

public extension Array where Iterator.Element: Codable {
    public func paginate<P: Paginator>(
        for req: Request
    ) throws -> Future<P> where
        P: ArrayPaginatable,
        P.Object == Iterator.Element,
        P.ResultObject == Iterator.Element,
        P.PaginatorMetaData == P.PaginatableMetaData
    {
        return try P.paginate(query: self, on: req).map { args -> P in
            let (results, data) = args
            return try P.init(data: results, meta: data)
        }
    }
}

extension Array: Transformable where Iterator.Element: Codable {
    public typealias TransformableQuery = [Iterator.Element]
    public typealias TransformableQueryResult = Iterator.Element
}

public extension TransformingQuery {
    public func paginate<P: Paginator>(
        for req: Request
    ) throws -> Future<P> where
        P: ArrayPaginatable,
        P.PaginatorMetaData == P.PaginatableMetaData,
        TransformedResult == P.Object,
        Query == Array<Result>
    {
        return try P.paginate(query: self.query, on: req).flatMap { args -> Future<P> in
            let (results, data) = args
            return try self.transform(results).map { results in
                return try P.init(data: results, meta: data)
            }
        }
    }
}
