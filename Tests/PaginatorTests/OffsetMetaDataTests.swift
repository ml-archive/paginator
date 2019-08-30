import XCTest
import Vapor
@testable import Paginator

class OffsetMetaDataTests: XCTestCase {
    
    static var allTests : [(String, (OffsetMetaDataTests) -> () throws -> Void)] {
        return [
            ("testInit", testInit),
            ("testZeroInit", testZeroInit),
            ("testZeroPerPageInit", testZeroPerPageInit),
        ]
    }
    
    func testInit() throws {
        
        let app = try Application()
        let req = Request(using: app)
        
        let metaData = try OffsetMetaData(currentPage: 0, perPage: 10, total: 200, on: req)
        
        XCTAssertEqual(metaData.currentPage, 0)
        XCTAssertEqual(metaData.perPage, 10)
        XCTAssertEqual(metaData.total, 200)
        XCTAssertEqual(metaData.totalPages, 20)
    }
    
    func testZeroInit() throws {
        
        let app = try Application()
        let req = Request(using: app)
        
        let metaData = try OffsetMetaData(currentPage: 0, perPage: 0, total: 0, on: req)
        
        XCTAssertEqual(metaData.currentPage, 0)
        XCTAssertEqual(metaData.perPage, 0)
        XCTAssertEqual(metaData.total, 0)
        XCTAssertEqual(metaData.totalPages, 0)
    }
    
    func testZeroPerPageInit() throws {
        
        let app = try Application()
        let req = Request(using: app)

        XCTAssertThrowsError(try OffsetMetaData(currentPage: 0, perPage: 0, total: 10, on: req))
    }
}
