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

    func testTransformerInputFutureOutput() throws {
        let inputData = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let expectedOutput = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        let eventLoop = EmbeddedEventLoop()

        let transformer = Transformer<Int, String>({ (input: [Int]) -> Future<[String]> in
            return eventLoop.future(input.map { $0.description })
        })

        let transformedData: [String] = try transformer
            .transform(eventLoop.future(inputData))
            .wait()

        XCTAssertEqual(transformedData, expectedOutput)
    }

    func testTransformerInputOutputNoArrays() throws {
        let inputData = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let expectedOutput = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        let eventLoop = EmbeddedEventLoop()

        let transformer = Transformer<Int, String>({ (input: Int) -> String in
            return input.description
        })

        let transformedData: [String] = try transformer
            .transform(eventLoop.future(inputData))
            .wait()

        XCTAssertEqual(transformedData, expectedOutput)
    }

    func testTransformerInputFutureOutputNoArrays() throws {
        let inputData = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let expectedOutput = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        let eventLoop = EmbeddedEventLoop()

        let transformer = Transformer<Int, String>({ (input: Int) -> Future<String> in
            return eventLoop.future(input.description)
        })

        let transformedData: [String] = try transformer
            .transform(eventLoop.future(inputData))
            .wait()

        XCTAssertEqual(transformedData, expectedOutput)
    }

    func testTransformerInputSameOutputNoArrays() throws {
        let inputData = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let eventLoop = EmbeddedEventLoop()

        let transformer = Transformer<Int, Int>()

        let transformedData: [Int] = try transformer
            .transform(eventLoop.future(inputData))
            .wait()

        XCTAssertEqual(transformedData, inputData)
    }

}
