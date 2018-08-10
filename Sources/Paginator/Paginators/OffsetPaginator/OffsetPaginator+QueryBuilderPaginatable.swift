import Fluent
import Vapor

extension OffsetPaginator: QueryBuilderPaginatable {
    public static func paginate<D: Database, Result>(
        count: Future<Int>,
        query: QueryBuilder<D, Result>,
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
                    return query.range(lower: lower, upper: upper).all()
                        .map { ($0, data) }
                }
            }
    }
}
