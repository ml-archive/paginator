import Vapor

public protocol ArrayPaginatable: Paginatable {
    associatedtype PaginatableMetaData

    static func paginate(
        query: [ResultObject],
        on req: Request
    ) throws -> Future<([ResultObject], PaginatableMetaData)>
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
