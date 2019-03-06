import Fluent
import Vapor

public protocol Paginator: Content {
    associatedtype Object: Codable
    associatedtype PaginatorMetaData

    init(data: [Object], meta: PaginatorMetaData?) throws

    var data: [Object]? { get }
    func metaData() -> PaginatorMetaData?
}
