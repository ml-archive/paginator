import HTTP
import JSON

extension Paginator: JSONRepresentable, ResponseRepresentable {
    public func makeResponse() throws -> Response {
        return try makeJSON().makeResponse()
    }
    
    public func makeJSON() throws -> JSON {
        let node = try makeNode(in: nil)
        return JSON(node: node)
    }
}
