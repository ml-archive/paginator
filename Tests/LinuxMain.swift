import XCTest

@testable import PaginatorTests

XCTMain([
    testCase(EntityTest.allTests),
    testCase(LeafTests.allTests),
    testCase(PaginatorTests.allTests),
])
