import XCTest
import Vapor
@testable import Paginator

class OffsetMetadataTests: XCTestCase {

    func testInitNoRequest() throws {
        let url: URL = URL(string: "https://www.google.com")!
        let params = OffsetParameters(page: 1, perPage: 10)
        let metadata = try OffsetMetadata(parameters: params, total: 200, url: url)

        XCTAssertEqual(metadata.currentPage, 1)
        XCTAssertEqual(metadata.perPage, 10)
        XCTAssertEqual(metadata.total, 200)
        XCTAssertEqual(metadata.totalPages, 20)
    }

    func testZeroInitNoRequest() throws {
        let url: URL = URL(string: "https://www.google.com")!
        let params = OffsetParameters(page: 1, perPage: 10)
        let metadata = try OffsetMetadata(parameters: params, total: 0, url: url)

        XCTAssertEqual(metadata.currentPage, 1)
        XCTAssertEqual(metadata.perPage, 10)
        XCTAssertEqual(metadata.total, 0)
        XCTAssertEqual(metadata.totalPages, 1)
    }

    func testZeroPerPageInitNoRequest() throws {
        let url: URL = URL(string: "https://www.google.com")!
        let params = OffsetParameters(page: 1, perPage: 0)

        let metadata = try OffsetMetadata(parameters: params, total: 0, url: url)

        XCTAssertEqual(metadata.currentPage, 1)
        XCTAssertEqual(metadata.perPage, 1)
        XCTAssertEqual(metadata.total, 0)
        XCTAssertEqual(metadata.totalPages, 1)
    }

    func testPageZeroInitNoRequest() throws {
        let url: URL = URL(string: "https://www.google.com")!
        let params = OffsetParameters(page: 0, perPage: 0)

        let metadata = try OffsetMetadata(parameters: params, total: 0, url: url)

        XCTAssertEqual(metadata.currentPage, 1)
        XCTAssertEqual(metadata.perPage, 1)
        XCTAssertEqual(metadata.total, 0)
        XCTAssertEqual(metadata.totalPages, 1)
    }

    func testInvalidPageInitNoRequest() throws {
        let url: URL = URL(string: "https://www.google.com")!
        let params = OffsetParameters(page: 11, perPage: 10)

        let metadata = try OffsetMetadata(parameters: params, total: 100, url: url)

        XCTAssertEqual(metadata.currentPage, 10)
        XCTAssertEqual(metadata.perPage, 10)
        XCTAssertEqual(metadata.total, 100)
        XCTAssertEqual(metadata.totalPages, 10)
    }

    func testNextAndPreviousLinksFirstPage() throws {
        let current = 1
        let total = 10
        let url: URL = URL(string: "https://www.google.com")!

        let links = try OffsetMetadata.nextAndPreviousLinks(
            currentPage: current,
            totalPages: total,
            url: url
        )

        XCTAssert(links as Any is (String?, String?))
        XCTAssertEqual(links.previous, nil)
        XCTAssertEqual(
            links.next,
            url.absoluteString + "?page=2"
        )
    }

    func testNextAndPreviousLinksLastPage() throws {
        let current = 10
        let total = 10
        let url: URL = URL(string: "https://www.google.com")!

        let links = try OffsetMetadata.nextAndPreviousLinks(
            currentPage: current,
            totalPages: total,
            url: url
        )

        XCTAssert(links as Any is (String?, String?))
        XCTAssertEqual(links.next, nil)
        XCTAssertEqual(
            links.previous,
            url.absoluteString + "?page=9"
        )
    }

    func testNextAndPreviousLinksMiddlePage() throws {
        let current = 5
        let total = 10
        let url: URL = URL(string: "https://www.google.com")!

        let links = try OffsetMetadata.nextAndPreviousLinks(
            currentPage: current,
            totalPages: total,
            url: url
        )

        XCTAssert(links as Any is (String?, String?))
        XCTAssertEqual(
            links.next,
            url.absoluteString + "?page=6"
        )
        XCTAssertEqual(
            links.previous,
            url.absoluteString + "?page=4"
        )
    }

    func testNextAndPreviousLinksInvalidPage() throws {
        let current = 15
        let total = 10
        let url: URL = URL(string: "https://www.google.com")!

        let links = try OffsetMetadata.nextAndPreviousLinks(
            currentPage: current,
            totalPages: total,
            url: url
        )

        XCTAssert(links as Any is (String?, String?))
        XCTAssertEqual(links.next, nil)
        XCTAssertEqual(
            links.previous,
            url.absoluteString + "?page=\(total)"
        )
    }
 }
