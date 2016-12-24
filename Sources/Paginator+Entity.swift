import HTTP
import Fluent

extension Entity {
    public func paginator(
        _ perPage: Int,
        columns: [String]? = nil,
        pageName: String = "page",
        page currentPage: Int? = nil,
        request: Request
        ) -> Paginator<Self>? {
        return Paginator(perPage: perPage, pageName: pageName, request: request)
    }
}
