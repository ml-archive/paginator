import XCTest
import Vapor
@testable import Paginator

class OffsetParametersTests: XCTestCase {

    func testInit() {
        let params = OffsetParameters(page: 1, perPage: 10)
        XCTAssertEqual(params.perPage, 10)
        XCTAssertEqual(params.page, 1)
    }

    // A page or perPage < 1 makes no sense so test the it will fallback to 1
    func testInitLessThanPageOne() {
        let params = OffsetParameters(page: 0, perPage: 10)
        XCTAssertEqual(params.perPage, 10)
        XCTAssertEqual(params.page, 1)
    }

    func testInitExtremeNegativePage() {
        let extreme: Int = Int.min
        let params = OffsetParameters(page: extreme, perPage: 10)
        XCTAssertEqual(params.perPage, 10)
        XCTAssertEqual(params.page, 1)
    }

    func testInitLessThanOnePerPage() {
        let params = OffsetParameters(page: 1, perPage: 0)
        XCTAssertEqual(params.perPage, 1)
        XCTAssertEqual(params.page, 1)
    }

    func testInitExtremeNegativePerPage() {
        let extreme: Int = Int.min
        let params = OffsetParameters(page: 1, perPage: extreme)
        XCTAssertEqual(params.perPage, 1)
        XCTAssertEqual(params.page, 1)
    }

    func testConfigAndEmptyQueryParameterInit() throws {
        let config = OffsetPaginatorConfig(perPage: 10, defaultPage: 1)
        let queryParameters = OffsetQueryParameters(perPage: nil, page: nil)

        let params = OffsetParameters(config: config, queryParameters: queryParameters)

        XCTAssertEqual(params.perPage, config.perPage)
        XCTAssertEqual(params.page, config.defaultPage)
    }

    func testConfigAndQueryParameterInit() throws {
        let config = OffsetPaginatorConfig(perPage: 10, defaultPage: 1)
        let queryParameters = OffsetQueryParameters(perPage: 20, page: 2)

        let params = OffsetParameters(config: config, queryParameters: queryParameters)

        XCTAssertEqual(params.perPage, queryParameters.perPage)
        XCTAssertEqual(params.page, queryParameters.page)
    }

    func testConfigAndInvalidQueryParameterInit() throws {
        let config = OffsetPaginatorConfig(perPage: 10, defaultPage: 1)
        let queryParameters = OffsetQueryParameters(perPage: -20, page: -2)

        let params = OffsetParameters(config: config, queryParameters: queryParameters)

        XCTAssertTrue(params.page > 0)
        XCTAssertTrue(params.perPage > 0)
    }
}
