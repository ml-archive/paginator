import Fluent
import SQL
import Vapor

public struct OffsetPaginationDataSource<Element> {
    let results: (Range<Int>) -> Future<[Element]>
    let totalCount: () -> Future<Int>

    public init(
        results: @escaping (Range<Int>) -> EventLoopFuture<[Element]>,
        totalCount: @escaping () -> EventLoopFuture<Int>
    ) {
        self.results = results
        self.totalCount = totalCount
    }

    public init(_ array: Array<Element>, on worker: Worker) {
        self.results = { range in
            worker.future(Array(array[range.clamped(to: 0..<array.count)]))
        }
        self.totalCount = {
            worker.future(array.count)
        }
    }

    public init<D: Database>(_ queryBuilder: QueryBuilder<D, Element>) {
        self.results = { range in
            queryBuilder.range(range).all()
        }
        self.totalCount = queryBuilder.count
    }
}

extension OffsetPaginationDataSource where Element: Decodable {
    struct CountResult: Codable {
        let count: Int
    }

    public init<C: DatabaseConnection>(
        resultBuilder: SQLRawBuilder<C>,
        countBuilder: SQLRawBuilder<C>
    ) {
        self.results = { range in
            let resultBuilderCopy = resultBuilder.copy()
            resultBuilderCopy.sql.append(
                "\nLIMIT \(range.lowerBound - range.upperBound)\nOFFSET \(range.lowerBound)"
            )
            return resultBuilder.all(decoding: Element.self)
        }
        self.totalCount = {
            countBuilder.first(decoding: CountResult.self).map { $0?.count ?? 0 }
        }
    }
}

private extension SQLRawBuilder {
    func copy() -> SQLRawBuilder {
        let copy = SQLRawBuilder(sql, on: connectable)
        copy.binds = binds
        return copy
    }
}

public extension OffsetPaginationDataSource {
    func paginate<Output>(
        offsetMetaData: OffsetMetaData,
        transform: @escaping ([Element]) -> Future<[Output]>
    ) -> Future<OffsetPaginator<Output>> {
        results(offsetMetaData.range)
            .flatMap(transform)
            .map { data in
                OffsetPaginator(data: data, offsetMetaData: offsetMetaData)
            }
    }

    func paginate<Output>(
        offsetMetaData: OffsetMetaData,
        transform: @escaping ([Element]) -> [Output]
    ) -> Future<OffsetPaginator<Output>> {
        results(offsetMetaData.range)
            .map(transform)
            .map { data in
                OffsetPaginator(data: data, offsetMetaData: offsetMetaData)
            }
    }
}

public extension OffsetPaginationDataSource where Element: Codable {
    func paginate(
        offsetMetaData: OffsetMetaData
    ) -> Future<OffsetPaginator<Element>> {
        paginate(offsetMetaData: offsetMetaData) { $0 }
    }
}

// MARK: Creating `OffsetPaginator`s from `Request`s

public extension OffsetPaginationDataSource {
    func makeOffsetMetaData(on request: Request) -> EventLoopFuture<OffsetMetaData> {
        let config: OffsetPaginatorConfig = (try? request.make()) ?? .default

        return EventLoopFuture
            .flatMap(on: request) {
                try request.content.decode(OffsetQueryParams.self)
            }
            .and(totalCount())
            .map { params, count in
                try OffsetMetaData(
                    currentPage: params.page ?? config.defaultPage,
                    perPage: params.perPage ?? config.perPage,
                    total: count,
                    url: request.http.url
                )
            }
    }

    func paginate<Output>(
        on request: Request,
        transform: @escaping ([Element]) -> Future<[Output]>
    ) -> EventLoopFuture<OffsetPaginator<Output>> {
        makeOffsetMetaData(on: request).flatMap { offsetMetaData in
            self.paginate(offsetMetaData: offsetMetaData, transform: transform)
        }
    }
}

extension OffsetPaginationDataSource where Element: Codable {
    func paginate(on request: Request) -> EventLoopFuture<OffsetPaginator<Element>> {
        self.paginate(on: request, transform: request.future)
    }
}
