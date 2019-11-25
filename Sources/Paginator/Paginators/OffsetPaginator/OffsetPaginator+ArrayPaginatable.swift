import Vapor

extension OffsetPaginator: ArrayPaginatable {
    public typealias Query = [Object]

    // This shouldn't be called directly - please use the extension on Array instead.
    public static func paginate<Object>(
        source: [Object],
        count: Int,
        on req: Request
    ) throws -> Future<([Object], OffsetMetaData)> {
        return try offsetMetaData(count: count, on: req) { metadata in
            Future.map(on: req) {
                guard
                    metadata.currentPage <= metadata.totalPages,
                    metadata.currentPage > 0
                else {
                    return []
                }

                return Array(source[metadata.lower...metadata.upper])
            }
        }
    }
}
