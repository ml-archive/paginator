import HTTP
import Fluent

extension Entity {
    /**
        Constructs a paginator object.
     
        - Parameters:
            - perPage: How many entries per page.
            - page: Page number to be returned. The initializer will first
                attempt to decode the page number from the query string,
                defaulting to this value.
            - pageName: String to use for the query encoder/decoder. Default is `"page"`.
            - dataKey: JSON key to store the queried entities in. Default is `"data"`.
            - request: HTTP Request
     
        - Returns: Paginator
     */
    public static func paginator(
        _ perPage: Int,
        page currentPage: Int = 1,
        pageName: String = "page",
        dataKey: String = "data",
        request: Request
    ) throws -> Paginator<Self> {
        return try Paginator(
            query: Self.query(),
            currentPage: currentPage,
            perPage: perPage,
            pageName: pageName,
            dataKey: dataKey,
            request: request
        )
    }
}
