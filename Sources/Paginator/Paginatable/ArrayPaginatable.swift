import Vapor

public protocol ArrayPaginatable: Paginatable {
    associatedtype PaginatableMetaData

    static func paginate<Object>(
        source: [Object],
        count: Int,
        on req: Request
    ) throws -> Future<([Object], PaginatableMetaData)>
}

public extension ArrayPaginatable {
    static func paginate<Object>(
        source: [Object],
        on req: Request
    ) throws -> Future<([Object], PaginatableMetaData)> {
        return try self.paginate(source: source, count: source.count, on: req)
    }
}

public extension Array where Iterator.Element: Codable {
    func paginate<P: Paginator>(
        for req: Request
    ) throws -> Future<P> where
        P: ArrayPaginatable,
        P.Object == Iterator.Element,
        P.ResultObject == Iterator.Element,
        P.PaginatorMetaData == P.PaginatableMetaData
    {
        return try self.paginate(count: self.count, for: req)
    }

    func paginate<P: Paginator>(
        count: Int,
        for req: Request
    ) throws -> Future<P> where
        P: ArrayPaginatable,
        P.Object == Iterator.Element,
        P.ResultObject == Iterator.Element,
        P.PaginatorMetaData == P.PaginatableMetaData
    {
        return try P.paginate(source: self, count: count, on: req).map { args -> P in
            let (results, data) = args
            return try P(data: results, meta: data)
        }
    }
}

extension Array: Transformable where Iterator.Element: Codable {
    public typealias TransformableQuery = [Iterator.Element]
    public typealias TransformableQueryResult = Iterator.Element
}

public extension TransformingQuery {
    func paginate<P: Paginator>(
        for req: Request
    ) throws -> Future<P> where
        P: ArrayPaginatable,
        P.PaginatorMetaData == P.PaginatableMetaData,
        TransformedResult == P.Object,
        Query == [Result]
    {
        return try self.paginate(count: self.source.count, for: req)
    }

    func paginate<P: Paginator>(
        count: Int,
        for req: Request
    ) throws -> Future<P> where
        P: ArrayPaginatable,
        P.PaginatorMetaData == P.PaginatableMetaData,
        TransformedResult == P.Object,
        Query == [Result]
    {
        return try P.paginate(
            source: self.source,
            count: count,
            on: req
        )
        .flatMap { results, data -> Future<P> in
            try self.transform(results).map { results in
                return try P(data: results, meta: data)
            }
        }
    }
}
