import XCTest
import Vapor
@testable import Paginator

class TransformerTests: XCTestCase {
    func testTransformerInputOutput() throws {
        let inputData = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let expectedOutput = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

        let transformer = Transformer<Int, String>({ (input: [Int]) -> [String] in
                return input.map { $0.description }
            }
        )

        let eventLoop = EmbeddedEventLoop()

        let transformedData: [String] = try transformer
            .transform(eventLoop.future(inputData))
            .wait()

        XCTAssertEqual(transformedData, expectedOutput)
    }
}
