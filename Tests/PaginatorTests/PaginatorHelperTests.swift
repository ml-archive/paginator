import XCTest

import Vapor

@testable import Leaf
@testable import Paginator

class PaginatorHelperTests: XCTestCase {
    static var allTests = [
        ("testThatPathAreCorrectWhenGivingNodeNullAsUriQueries", testThatPathAreCorrectWhenGivingNodeNullAsUriQueries),
    ]

    func testThatPathAreCorrectWhenGivingNodeNullAsUriQueries() {
        let path = PaginatorHelper.buildPath(page: 1, count: 25, uriQueries: Node.null)
        XCTAssertEqual(path, "?page=1")
    }
}
