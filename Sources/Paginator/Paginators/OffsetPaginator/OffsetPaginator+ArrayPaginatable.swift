import Vapor

extension OffsetPaginator: ArrayPaginatable {
    public typealias Query = [Object]

    // This shouldn't be called directly - please use the extension on Array instead.
    public static func paginate<Object>(
        query: [Object],
        on req: Request
    ) throws -> EventLoopFuture<([Object], OffsetMetaData)> {
        let config: OffsetPaginatorConfig = (try? req.make()) ?? .default
        return try OffsetQueryParams.decode(req: req)
            .map { params in
                let count = query.count
                let perPage = params.perPage ?? config.perPage
                let totalPages = Int(ceil(Double(count) / Double(perPage)))

                let page = params.page ?? config.defaultPage
                let lower = (page - 1) * perPage
                var upper = (lower + perPage) - 1

                if upper >= count {
                    upper = count - 1
                }

                let data = try OffsetMetaData(
                    currentPage: page,
                    perPage: perPage,
                    total: count,
                    on: req
                )

                guard page <= totalPages && page > 0 else {
                    return ([], data)
                }

                return (Array(query[lower...upper]), data)
            }
    }
}
