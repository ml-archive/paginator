import XCTest
import Node

func assertUnorderedEquals(_ given: Node, _ expected: Node, file: StaticString = #file, line: UInt = #line) {
    var given = given

    expected.object?.forEach {
        XCTAssertEqual($0.value, given[$0.key], file: file, line: line)
        given.removeKey($0.key)
    }

    XCTAssertEqual(given.object?.count, 0, file: file, line: line)
}
