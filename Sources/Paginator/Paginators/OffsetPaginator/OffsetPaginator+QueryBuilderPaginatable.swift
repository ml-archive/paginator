import Fluent
import Vapor

extension OffsetPaginator: QueryBuilderPaginatable {
    // This shouldn't be called directly - please use the extension on QueryBuilder instead.
    public static func paginate<D: Database, Result>(
        source: QueryBuilder<D, Result>,
        count: Future<Int>,
        on req: Request
    ) throws -> Future<([Result], OffsetMetaData)> {
        return count.flatMap { count in
            try offsetMetaData(count: count, on: req) { metadata in
                source
                    .range(lower: metadata.lower, upper: metadata.upper)
                    .all()
            }
        }
    }
}
