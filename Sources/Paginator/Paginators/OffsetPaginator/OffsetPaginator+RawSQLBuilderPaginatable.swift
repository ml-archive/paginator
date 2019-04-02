import Fluent
import Vapor

extension OffsetPaginator: RawSQLBuilderPaginatable {
    // This shouldn't be called directly - please use the extension on QueryBuilder instead.
    static func paginate<D: Database, Result>(
        source: RawSQLBuilder<D, Result>,
        count: Future<Int>,
        on req: Request
        ) throws -> Future<([Result], OffsetMetaData)> {
        let config: OffsetPaginatorConfig = (try? req.make()) ?? .default
        return try OffsetQueryParams.decode(req: req)
            .flatMap { params in
                let page = params.page ?? config.defaultPage
                let perPage = params.perPage ?? config.perPage
                let lower = (page - 1) * perPage
                
                source.sqlRawBuilder.sql.append("""
                    
                    LIMIT \(perPage)
                    OFFSET \(lower)
                    """
                )
                return count.flatMap { count in
                    let data = try OffsetMetaData(
                        currentPage: page,
                        perPage: perPage,
                        total: count,
                        on: req
                    )
                    return source.sqlRawBuilder.all(decoding: Result.self).map({ output in
                        (output, data)
                    })
                }
        }
    }
}
