import XCTest
import Vapor
@testable import Paginator

class OffsetQueryParametersTests: XCTestCase {

    func testInitNilInput() {
        let params = OffsetQueryParameters(perPage: nil, page: nil)
        XCTAssertEqual(params.perPage, nil)
        XCTAssertEqual(params.page, nil)
    }

    func testInit() {
        let params = OffsetQueryParameters(perPage: 10, page: 1)
        XCTAssertEqual(params.perPage, 10)
        XCTAssertEqual(params.page, 1)
    }

    // Query params are often provided by users so we'll allow values
    // even though they make no sense in the pagination context
    // testing negative values in this case
    func testInitNegativePage() {
        let params = OffsetQueryParameters(perPage: 10, page: -1)
        XCTAssertEqual(params.perPage, 10)
        XCTAssertEqual(params.page, -1)
    }

    func testInitNegativePerPage() {
        let params = OffsetQueryParameters(perPage: -10, page: 1)
        XCTAssertEqual(params.perPage, -10)
        XCTAssertEqual(params.page, 1)
    }

    // and extremes
    func testInitExtremePositivePage() {
        let extreme = Int.max

        let params = OffsetQueryParameters(perPage: 10, page: extreme)
        XCTAssertEqual(params.perPage, 10)
        XCTAssertEqual(params.page, extreme)
    }

    func testInitExtremePositivePerPage() {
        let extreme = Int.max

        let params = OffsetQueryParameters(perPage: extreme, page: 1)
        XCTAssertEqual(params.perPage, extreme)
        XCTAssertEqual(params.page, 1)
    }

    func testInitExtremeNegativePage() {
        let extreme = Int.min

        let params = OffsetQueryParameters(perPage: 10, page: extreme)
        XCTAssertEqual(params.perPage, 10)
        XCTAssertEqual(params.page, extreme)
    }

    func testInitExtremeNegativePerPage() {
        let extreme: Int = Int.min

        let params = OffsetQueryParameters(perPage: extreme, page: 1)
        XCTAssertEqual(params.perPage, extreme)
        XCTAssertEqual(params.page, 1)
    }
}
