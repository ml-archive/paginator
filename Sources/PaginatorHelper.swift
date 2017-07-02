import Vapor

struct PaginatorHelper {
    static func buildPath(
        baseURI: String = "",
        page: Int,
        count: Int,
        uriQueries: Node?,
        pageName: String = "page"
    ) -> String? {
        var urlQueriesRaw = uriQueries ?? [:]
        urlQueriesRaw[pageName] = .number(.int(page))
        if urlQueriesRaw["count"]?.string != nil {
            urlQueriesRaw["count"] = .number(.int(count))
        }

        guard let urlQueries = urlQueriesRaw.formEncode() else { return nil }

        return [
            baseURI,
            "?",
            urlQueries
        ].joined()
    }
}
