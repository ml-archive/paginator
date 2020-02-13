import Vapor

public extension OffsetMetadata {
    static func nextAndPreviousLinks(
        currentPage: Int,
        totalPages: Int,
        url: URL
    ) throws -> (previous: String?, next: String?) {
        var previous: String? = nil
        var next: String? = nil

        if currentPage > 1 {
            let previousPage = (currentPage <= totalPages) ? currentPage - 1 : totalPages
            previous = try link(url: url, page: previousPage)
        }

        if currentPage < totalPages {
            next = try link(url: url, page: currentPage + 1)
        }

        return (previous, next)
    }

    func links(
        in range: CountableClosedRange<Int>
    ) throws -> [String] {
        return try range.map { try link(for: $0) }
    }

    func link(
        for page: Int
    ) throws -> String {
        return try OffsetMetadata.link(url: self.url, page: page)
    }

    private static func link(url: URL, page: Int) throws -> String {
        guard
            let pageName = try OffsetQueryParameters.reflectProperty(forKey: \.page)?.path.last,
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            throw Abort(.internalServerError)
        }

        var queryItems = components.queryItems?.filter { $0.name != pageName } ?? []
        queryItems.append(URLQueryItem(name: pageName, value: String(page)))
        components.queryItems = queryItems

        guard let url = components.url?.absoluteString else {
            throw Abort(.internalServerError)
        }

        return url
    }
}
