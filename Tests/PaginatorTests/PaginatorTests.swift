import XCTest
@testable import Paginator

class PaginatorTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(Paginator().text, "Hello, World!")
    }


    static var allTests : [(String, (PaginatorTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
