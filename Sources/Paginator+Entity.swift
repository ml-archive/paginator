import HTTP
import Fluent

extension Entity {
    public static func paginator(
        _ perPage: Int,
        columns: [String]? = nil,
        pageName: String = "page",
        page currentPage: Int? = nil,
        request: Request
    ) throws -> Paginator<Self> {
        return try Paginator(
            perPage: perPage,
            pageName: pageName,
            request: request
        )
    }
}
