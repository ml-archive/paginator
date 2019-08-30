import XCTest

@testable import PaginatorTests

XCTMain([
    testCase(PaginatorTests.allTests),
    testCase(OffsetMetaDataTests.allTests),
])
