import Vapor

public protocol Paginatable: Codable {
    associatedtype Query
    associatedtype ResultObject
    associatedtype PaginatableMetaData

    static func paginate(
        source: Query,
        on req: Request
    ) throws -> Future<([ResultObject], PaginatableMetaData)>
}
