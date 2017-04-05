import XCTest

@testable import PaginatorTests

XCTMain([
    testCase(EntityTest.allTests),
    testCase(SequenceTests.allTests),
    testCase(LeafTests.allTests),
    testCase(PaginatorTests.allTests),
])
