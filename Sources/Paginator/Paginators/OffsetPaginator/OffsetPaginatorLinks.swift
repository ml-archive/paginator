import Vapor

public extension OffsetMetaData {
    public static func links(
        currentPage: Int,
        totalPages: Int,
        on req: Request
    ) throws -> (previous: String?, next: String?) {
        func link(url: URL, page: Int) throws -> String {
            guard
                let pageName = try OffsetQueryParams.reflectProperty(forKey: \.page)?.path.last,
                var components = URLComponents(url: req.http.url, resolvingAgainstBaseURL: false)
            else {
                throw Abort.init(.internalServerError)
            }

            var queryItems = components.queryItems?.filter { $0.name != pageName } ?? []
            queryItems.append(URLQueryItem(name: pageName, value: String(page)))
            components.queryItems = queryItems

            guard let url = components.url?.absoluteString else {
                throw Abort.init(.internalServerError)
            }

            return url
        }

        var previous: String? = nil
        var next: String? = nil

        if currentPage > 1 {
            let previousPage = (currentPage <= totalPages) ? currentPage - 1 : totalPages
            previous = try link(url: req.http.url, page: previousPage)
        }

        if currentPage < totalPages {
            next = try link(url: req.http.url, page: currentPage + 1)
        }

        return (previous, next)
    }
}

