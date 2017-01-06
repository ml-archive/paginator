import XCTest

import Leaf
import Vapor

class LeafTests: XCTestCase {
    static var allTest = [
        ("testExample", testExample)
    ]
    
    func testExample() {
        XCTAssertEqual(2+2, 4)
    }
}
