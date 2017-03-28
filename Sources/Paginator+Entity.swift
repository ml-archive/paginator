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
        paginatorName: String = "paginator",
        pageName: String = "page",
        dataKey: String = "data",
        request: Request,
        transform: (([Self]) throws -> Node)? = nil
    ) throws -> Paginator<Self> {
        return try Paginator(
            query: Self.query(),
            currentPage: currentPage,
            perPage: perPage,
            paginatorName: paginatorName,
            pageName: pageName,
            dataKey: dataKey,
            transform: transform,
            request: request
        )
    }
}

extension Query {
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
    public func paginator(
        _ perPage: Int,
        page currentPage: Int = 1,
        paginatorName: String = "paginator",
        pageName: String = "page",
        dataKey: String = "data",
        request: Request,
        transform: (([T]) throws -> Node)? = nil
    ) throws -> Paginator<T> {
        return try Paginator(
            query: self,
            currentPage: currentPage,
            perPage: perPage,
            paginatorName: paginatorName,
            pageName: pageName,
            dataKey: dataKey,
            transform: transform,
            request: request
        )
    }
}

extension Sequence where Iterator.Element: Entity {
    public func paginator(
        _ perPage: Int,
        page currentPage: Int = 1,
        paginatorName: String = "paginator",
        pageName: String = "page",
        dataKey: String = "data",
        request: Request
    ) throws -> Paginator<Iterator.Element> {
        return try Paginator<Iterator.Element>(
            Array(self),
            page: currentPage,
            perPage: perPage,
            paginatorName: paginatorName,
            pageName: pageName,
            dataKey: dataKey,
            request: request
        )
    }
}
