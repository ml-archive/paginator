import XCTest
import Vapor
@testable import Paginator

class OffsetPaginationDataSourceTests: XCTestCase {
    func testDataSourcePaginate() throws {
        let data = [1,2,3,4,5,6,7]
        let parameters = OffsetParameters(page: 1, perPage: 1)
        let url = URL(string: "https://www.google.com")!

        let eventLoop = EmbeddedEventLoop()
        let dataSource = OffsetPaginationDataSource(
            results: { _ in
                return eventLoop.future(data)
            },
            totalCount: {
                return eventLoop.future(data.count)
            }
        )

        let paginator = try dataSource.paginate(parameters: parameters, url: url).wait()

        XCTAssertEqual(paginator.data, data)
        XCTAssertEqual(paginator.metadata.currentPage, 1)
        XCTAssertEqual(paginator.metadata.totalPages, data.count)
        XCTAssertEqual(paginator.metadata.perPage, 1)
        XCTAssertEqual(paginator.metadata.links.previous, nil)
        XCTAssertEqual(paginator.metadata.links.next, url.absoluteString + "?page=2")
    }
}
