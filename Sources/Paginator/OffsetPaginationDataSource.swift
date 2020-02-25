import NIO

public struct OffsetPaginationDataSource<Element> {
    let results: (Range<Int>) -> EventLoopFuture<[Element]>
    let totalCount: () -> EventLoopFuture<Int>

    public init(
        results: @escaping (Range<Int>) -> EventLoopFuture<[Element]>,
        totalCount: @escaping () -> EventLoopFuture<Int>
    ) {
        self.results = results
        self.totalCount = totalCount
    }
}
