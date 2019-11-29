import XCTest
import Vapor
@testable import Paginator

class OffsetMetadataTests: XCTestCase {
    
    static var allTests : [(String, (OffsetMetadataTests) -> () throws -> Void)] {
        return [
            ("testInit", testInit),
            ("testZeroInit", testZeroInit),
            ("testZeroPerPageInit", testZeroPerPageInit),
        ]
    }
    
    func testInit() throws {
        
        let app = try Application()
        let req = Request(using: app)
        
        let metadata = try OffsetMetadata(currentPage: 0, perPage: 10, total: 200, on: req)
        
        XCTAssertEqual(metadata.currentPage, 0)
        XCTAssertEqual(metadata.perPage, 10)
        XCTAssertEqual(metadata.total, 200)
        XCTAssertEqual(metadata.totalPages, 20)
    }
    
    func testZeroInit() throws {
        
        let app = try Application()
        let req = Request(using: app)
        
        let metadata = try OffsetMetadata(currentPage: 0, perPage: 0, total: 0, on: req)
        
        XCTAssertEqual(metadata.currentPage, 0)
        XCTAssertEqual(metadata.perPage, 0)
        XCTAssertEqual(metadata.total, 0)
        XCTAssertEqual(metadata.totalPages, 0)
    }
    
    func testZeroPerPageInit() throws {
        
        let app = try Application()
        let req = Request(using: app)

        XCTAssertThrowsError(try OffsetMetadata(currentPage: 0, perPage: 0, total: 10, on: req))
    }

    func testInitNoRequest() throws {
        let url: URL = URL(string: "https://www.google.com")!
        let metadata = try OffsetMetadata(currentPage: 0, perPage: 10, total: 200, url: url)

        XCTAssertEqual(metadata.currentPage, 0)
        XCTAssertEqual(metadata.perPage, 10)
        XCTAssertEqual(metadata.total, 200)
        XCTAssertEqual(metadata.totalPages, 20)
    }

    func testZeroInitNoRequest() throws {
        let url: URL = URL(string: "https://www.google.com")!
        let metadata = try OffsetMetadata(currentPage: 0, perPage: 0, total: 0, url: url)

        XCTAssertEqual(metadata.currentPage, 0)
        XCTAssertEqual(metadata.perPage, 0)
        XCTAssertEqual(metadata.total, 0)
        XCTAssertEqual(metadata.totalPages, 0)
    }

    func testZeroPerPageInitNoRequest() throws {
        let url: URL = URL(string: "https://www.google.com")!
        XCTAssertThrowsError(try OffsetMetadata(currentPage: 0, perPage: 0, total: 10, url: url))
    }
/*
    func testNextAndPreviousLinksFirstPage() {
        let current = 1
        let total = 10
        let url: URL = URL(string: "https://www.google.com")!

        let links = OffsetMetadata.nextAndPreviousLinks(
            currentPage: current,
            totalPages: total,
            url: url
        )
    }
*/
 }
