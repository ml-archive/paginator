import Fluent
import Vapor

extension OffsetPaginator: QueryBuilderPaginatable {
    // This shouldn't be called directly - please use the extension on QueryBuilder instead.
    public static func paginate<D: Database, Result>(
        source: QueryBuilder<D, Result>,
        count: Future<Int>,
        on req: Request
    ) throws -> Future<([Result], OffsetMetaData)> {
        let config: OffsetPaginatorConfig = (try? req.make()) ?? .default
        return try OffsetQueryParams.decode(req: req)
            .flatMap { params in
                let page = params.page ?? config.defaultPage
                let perPage = params.perPage ?? config.perPage
                let lower = (page - 1) * perPage
                let upper = (lower + perPage) - 1

                return count.flatMap { count in
                    let data = try OffsetMetaData(
                        currentPage: page,
                        perPage: perPage,
                        total: count,
                        on: req
                    )
                    return source
                        .range(lower: lower, upper: upper)
                        .all()
                        .map { ($0, data) }
                }
            }
    }
}

