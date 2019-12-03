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
                self.range(range).all()
            },
            totalCount: count
        )
    }
}

extension OffsetPaginationDataSource: OffsetPaginatable {
    public func makeOffsetPaginationDataSource() -> OffsetPaginationDataSource<Element> {
        return self
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
    func paginate<Output>(
        parameters: OffsetParameters,
        url: URL,
        transformer: Transformer<Element, Output>
    ) -> Future<OffsetPaginator<Output>> {
        let source = makeOffsetPaginationDataSource()
        return transformer.transform(source.results(parameters.range))
            .and(source.totalCount())
            .map { data, count in
                try OffsetPaginator(
                    data: data,
                    metadata: .init(
                        parameters: parameters,
                        total: count,
                        url: url
                    )
                )
            }
    }
}

public extension OffsetPaginatable where Element: Codable {
    func paginate(
        parameters: OffsetParameters,
        url: URL
    ) -> Future<OffsetPaginator<Element>> {
        return paginate(parameters: parameters, url: url, transformer: .init())
    }
}

// MARK: Creating `OffsetPaginator`s from `Request`s

public extension OffsetPaginatable {
    func paginate<Output>(
        on request: Request,
        transformer: Transformer<Element, Output>
    ) -> EventLoopFuture<OffsetPaginator<Output>> {
        return request.offsetParameters().flatMap {
            self.paginate(parameters: $0, url: request.http.url, transformer: transformer)
        }
    }
}

public extension Request {
    func offsetParameters() -> EventLoopFuture<OffsetParameters> {
        return EventLoopFuture.map(on: self) {
            try self.query.decode(OffsetQueryParameters.self)
        }.map {
            OffsetParameters(config: (try? self.make()) ?? .default, queryParameters: $0)
        }
    }
}

public extension OffsetPaginatable where Element: Codable {
    func paginate(on request: Request) -> EventLoopFuture<OffsetPaginator<Element>> {
        return paginate(on: request, transformer: .init())
    }
}
