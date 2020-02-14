import XCTest
import Vapor
@testable import Paginator

private let metadata = try! OffsetMetadata(
    parameters: .init(page: 1, perPage: 2),
    total: 2,
    url: URL(string: "a.b")!
)

final class OffsetPaginatorMapTests: XCTestCase {
    func testMap() {
        let paginator = OffsetPaginator(data: [1, 2], metadata: metadata)
        let mapped = paginator.map { $0.map(String.init) }
        XCTAssertEqual(mapped.data, ["1", "2"])
    }

    func testMapSingle() {
        let paginator = OffsetPaginator(data: [1, 2], metadata: metadata)
        let mapped = paginator.map { $0.description }
        XCTAssertEqual(mapped.data, ["1", "2"])
    }

    func testAsyncMap() throws {
        let eventloop = EmbeddedEventLoop()
        let paginator = OffsetPaginator(data: [1, 2], metadata: metadata)
        let mapped = try paginator.map { eventloop.future($0.map(String.init)) }.wait()
        XCTAssertEqual(mapped.data, ["1", "2"])
    }
}
