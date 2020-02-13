import Fluent
import SQL
import Vapor

public protocol OffsetPaginatable {
    associatedtype Element
    func makeOffsetPaginationDataSource() -> OffsetPaginationDataSource<Element>
}

extension EventLoopFuture: OffsetPaginatable where T: Collection, T.Index == Int {
    public typealias Element = T.Element
    public func makeOffsetPaginationDataSource() -> OffsetPaginationDataSource<T.Element> {
        return .init(
            results: { range in self.map { Array($0[range.clamped(to: 0..<$0.count)]) } },
            totalCount: { self.map { $0.count } }
        )
    }
}

extension QueryBuilder: OffsetPaginatable {

    /// Make an OffsetPaginationDataSource from the query builder.
    public func makeOffsetPaginationDataSource() -> OffsetPaginationDataSource<Result> {
        return .init(
            results: { range in
                self.copy().range(range).all()
            },
            totalCount: copy().count
        )
    }
}

extension OffsetPaginationDataSource: OffsetPaginatable {
    public func makeOffsetPaginationDataSource() -> OffsetPaginationDataSource<Element> {
        return self
    }
}

extension OffsetPaginationDataSource where Element: Decodable {
    struct CountResult: Decodable {
        let count: Int
    }

    public init<C: DatabaseConnection>(
        resultBuilder: SQLRawBuilder<C>,
        countBuilder: SQLRawBuilder<C>
    ) {
        self.results = { range in
            let resultBuilderCopy = resultBuilder.copy()
            resultBuilderCopy.sql.append(
                "\nLIMIT \(range.upperBound - range.lowerBound)\nOFFSET \(range.lowerBound)"
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

public extension OffsetPaginatable {
    func paginate(
        parameters: OffsetParameters,
        url: URL
    ) -> Future<OffsetPaginator<Element>> {
        let source = makeOffsetPaginationDataSource()
        return source
            .results(parameters.range)
            .flatMap { results in
                source.totalCount().map { count in
                    try OffsetPaginator(
                        data: results,
                        metadata: .init(
                            parameters: parameters,
                            total: count,
                            url: url
                        )
                    )
                }
            }
    }
}

// MARK: Creating `OffsetPaginator`s from `Request`s

public extension OffsetPaginatable {
    func paginate(
        on request: Request
    ) -> EventLoopFuture<OffsetPaginator<Element>> {
        return request.offsetParameters().flatMap {
            self.paginate(parameters: $0, url: request.http.url)
        }
    }
}

public extension Request {
    func offsetParameters() -> EventLoopFuture<OffsetParameters> {
        return EventLoopFuture.map(on: self) {
            try self.query.decode(OffsetQueryParameters.self)
        }.map {
            OffsetParameters(
                config: (try? self.make(OffsetPaginatorConfig.self)) ?? .default,
                queryParameters: $0
            )
        }
    }
}
