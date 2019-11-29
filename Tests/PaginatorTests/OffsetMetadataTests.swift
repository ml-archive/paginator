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
}
