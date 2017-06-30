import XCTest

import Vapor

@testable import Leaf
@testable import Paginator

class LeafTests: XCTestCase {
    static var allTests = [
        ("testRunTag", testRunTag),
        ("testRunTagWithAriaLabel", testRunTagWithAriaLabel),
        ("testRunTagWithExplicitBootstrap3", testRunTagWithExplicitBootstrap3),
        ("testRunTagWithBootstrap4", testRunTagWithBootstrap4),
        ("testRunTagWithBootstrap4AndAriaLabel", testRunTagWithBootstrap4AndAriaLabel),
        ("testNoPreviousPageWithBootstrap3", testNoPreviousPageWithBootstrap3),
        ("testNoNextPageWithBootstrap3", testNoNextPageWithBootstrap3),
        ("testNoPreviousPageWithBootstrap4", testNoPreviousPageWithBootstrap4),
        ("testNoNextPageWithBootstrap4", testNoNextPageWithBootstrap4),
        ("testRunTagFailedTwoArgs", testRunTagFailedTwoArgs),
    ]
    
    func testRunTag() {
        let tag = PaginatorTag()
        let paginator = buildPaginator()
        
        let result = expectNoThrow() {
            return try run(
                tag: tag,
                context: paginator,
                arguments: [
                    .variable(path: [], value: paginator)
                ]
            )

        }!
        
        guard result != nil, case .bytes(let bytes) = result! else {
            XCTFail("Should have returned bytes")
            return
        }
        
        let expectedHTML =
            "<nav class=\"paginator text-center\">\n" +
                "<ul class=\"pagination\">\n" +
                    "<li>" +
                        "<a href=\"?page=1\" rel=\"prev\" aria-label=\"Previous\">" +
                            "<span aria-hidden=\"true\">«</span><span class=\"sr-only\">Previous</span>" +
                        "</a>" +
                    "</li>\n" +
                    "<li><a href=\"?page=1\">1</a></li>\n" +
                    "<li class=\"active\"><a>" +
                        "<span>2</span><span class=\"sr-only\">(current)</span></a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=3\">3</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=4\">4</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=5\">5</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=6\">6</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=7\">7</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=8\">8</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=9\">9</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=10\">10</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=3\" rel=\"next\" aria-label=\"Next\">" +
                            "<span aria-hidden=\"true\">»</span>" +
                            "<span class=\"sr-only\">Next</span>" +
                        "</a>" +
                    "</li>\n" +
                "</ul>\n" +
            "</nav>"
        
        XCTAssertEqual(bytes.string, expectedHTML)
    }
    
    func testRunTagWithAriaLabel() {
        let tag = PaginatorTag(paginationLabel: "Some Aria Label Pages")
        let paginator = buildPaginator()
        
        let result = expectNoThrow() {
            return try run(
                tag: tag,
                context: paginator,
                arguments: [
                    .variable(path: [], value: paginator)
                ]
            )
            
            }!
        
        guard result != nil, case .bytes(let bytes) = result! else {
            XCTFail("Should have returned bytes")
            return
        }
        
        let expectedHTML =
            "<nav class=\"paginator text-center\" aria-label=\"Some Aria Label Pages\">\n" +
                "<ul class=\"pagination\">\n" +
                    "<li>" +
                        "<a href=\"?page=1\" rel=\"prev\" aria-label=\"Previous\">" +
                            "<span aria-hidden=\"true\">«</span><span class=\"sr-only\">Previous</span>" +
                        "</a>" +
                    "</li>\n" +
                    "<li><a href=\"?page=1\">1</a></li>\n" +
                    "<li class=\"active\"><a>" +
                        "<span>2</span><span class=\"sr-only\">(current)</span></a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=3\">3</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=4\">4</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=5\">5</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=6\">6</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=7\">7</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=8\">8</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=9\">9</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=10\">10</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=3\" rel=\"next\" aria-label=\"Next\">" +
                            "<span aria-hidden=\"true\">»</span>" +
                            "<span class=\"sr-only\">Next</span>" +
                        "</a>" +
                    "</li>\n" +
                "</ul>\n" +
        "</nav>"
        
        XCTAssertEqual(bytes.string, expectedHTML)
    }
    
    func testRunTagWithExplicitBootstrap3() {
        let tag = PaginatorTag(useBootstrap4: false)
        let paginator = buildPaginator()
        
        let result = expectNoThrow() {
            return try run(
                tag: tag,
                context: paginator,
                arguments: [
                    .variable(path: [], value: paginator)
                ]
            )
            
            }!
        
        guard result != nil, case .bytes(let bytes) = result! else {
            XCTFail("Should have returned bytes")
            return
        }
        
        let expectedHTML =
            "<nav class=\"paginator text-center\">\n" +
                "<ul class=\"pagination\">\n" +
                    "<li>" +
                        "<a href=\"?page=1\" rel=\"prev\" aria-label=\"Previous\">" +
                            "<span aria-hidden=\"true\">«</span><span class=\"sr-only\">Previous</span>" +
                        "</a>" +
                    "</li>\n" +
                    "<li><a href=\"?page=1\">1</a></li>\n" +
                    "<li class=\"active\"><a>" +
                        "<span>2</span><span class=\"sr-only\">(current)</span></a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=3\">3</a>" +
                    "</li>\n" +
                    "<li><a href=\"?page=4\">4</a>" +
                    "</li>\n" +
                    "<li><a href=\"?page=5\">5</a>" +
                    "</li>\n" +
                    "<li><a href=\"?page=6\">6</a>" +
                    "</li>\n" +
                    "<li><a href=\"?page=7\">7</a>" +
                    "</li>\n" +
                    "<li><a href=\"?page=8\">8</a>" +
                    "</li>\n" +
                    "<li><a href=\"?page=9\">9</a>" +
                    "</li>\n" +
                    "<li><a href=\"?page=10\">10</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=3\" rel=\"next\" aria-label=\"Next\">" +
                            "<span aria-hidden=\"true\">»</span>" +
                            "<span class=\"sr-only\">Next</span>" +
                        "</a>" +
                    "</li>\n" +
                "</ul>\n" +
            "</nav>"
        
        XCTAssertEqual(bytes.string, expectedHTML)
    }
    
    func testRunTagWithBootstrap4() {
        let tag = PaginatorTag(useBootstrap4: true)
        let paginator = buildPaginator()
        
        let result = expectNoThrow() {
            return try run(
                tag: tag,
                context: paginator,
                arguments: [
                    .variable(path: [], value: paginator)
                ]
            )
            
            }!
        
        guard result != nil, case .bytes(let bytes) = result! else {
            XCTFail("Should have returned bytes")
            return
        }
        
        let expectedHTML =
            "<nav class=\"paginator\">\n" +
                "<ul class=\"pagination justify-content-center\">\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=1\" class=\"page-link\" rel=\"prev\" aria-label=\"Previous\">" +
                            "<span aria-hidden=\"true\">«</span>" +
                            "<span class=\"sr-only\">Previous</span>" +
                        "</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\"><a href=\"?page=1\" class=\"page-link\">1</a></li>\n" +
                    "<li class=\"active page-item\"><a>" +
                        "<span class=\"page-link\">2</span><span class=\"sr-only\">(current)</span></a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=3\" class=\"page-link\">3</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=4\" class=\"page-link\">4</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=5\" class=\"page-link\">5</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=6\" class=\"page-link\">6</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=7\" class=\"page-link\">7</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=8\" class=\"page-link\">8</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=9\" class=\"page-link\">9</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=10\" class=\"page-link\">10</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=3\" class=\"page-link\" rel=\"next\" aria-label=\"Next\">" +
                            "<span aria-hidden=\"true\">»</span>" +
                            "<span class=\"sr-only\">Next</span>" +
                        "</a>" +
                    "</li>\n" +
                "</ul>\n" +
            "</nav>"
        
        XCTAssertEqual(bytes.string, expectedHTML)
    }
    
    func testRunTagWithBootstrap4AndAriaLabel() {
        let tag = PaginatorTag(useBootstrap4: true, paginationLabel: "Some Pages")
        let paginator = buildPaginator()
        
        let result = expectNoThrow() {
            return try run(
                tag: tag,
                context: paginator,
                arguments: [
                    .variable(path: [], value: paginator)
                ]
            )
            
            }!
        
        guard result != nil, case .bytes(let bytes) = result! else {
            XCTFail("Should have returned bytes")
            return
        }
        
        let expectedHTML =
            "<nav class=\"paginator\" aria-label=\"Some Pages\">\n" +
                "<ul class=\"pagination justify-content-center\">\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=1\" class=\"page-link\" rel=\"prev\" aria-label=\"Previous\">" +
                            "<span aria-hidden=\"true\">«</span>" +
                            "<span class=\"sr-only\">Previous</span>" +
                        "</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\"><a href=\"?page=1\" class=\"page-link\">1</a></li>\n" +
                    "<li class=\"active page-item\"><a>" +
                        "<span class=\"page-link\">2</span><span class=\"sr-only\">(current)</span></a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=3\" class=\"page-link\">3</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=4\" class=\"page-link\">4</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=5\" class=\"page-link\">5</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=6\" class=\"page-link\">6</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=7\" class=\"page-link\">7</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=8\" class=\"page-link\">8</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=9\" class=\"page-link\">9</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=10\" class=\"page-link\">10</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=3\" class=\"page-link\" rel=\"next\" aria-label=\"Next\">" +
                            "<span aria-hidden=\"true\">»</span>" +
                            "<span class=\"sr-only\">Next</span>" +
                        "</a>" +
                    "</li>\n" +
                "</ul>\n" +
            "</nav>"
        
        XCTAssertEqual(bytes.string, expectedHTML)
    }
    
    func testNoPreviousPageWithBootstrap3() {
        let tag = PaginatorTag(useBootstrap4: false, paginationLabel: "Some Pages")
        let paginator = buildPaginator(currentPage: 1)
        
        let result = expectNoThrow() {
            return try run(
                tag: tag,
                context: paginator,
                arguments: [.variable(path: [], value: paginator)]
            )
            }!
        
        guard result != nil, case .bytes(let bytes) = result! else {
            XCTFail("Should have returned bytes")
            return
        }
        
        let expectedHTML =
            "<nav class=\"paginator text-center\" aria-label=\"Some Pages\">\n" +
                "<ul class=\"pagination\">\n" +
                    "<li class=\"disabled\">" +
                        "<a>" +
                            "<span aria-label=\"Previous\" aria-hidden=\"true\">«</span>" +
                            "<span class=\"sr-only\">Previous</span>" +
                        "</a>" +
                    "</li>\n" +
                    "<li class=\"active\">" +
                        "<a><span>1</span><span class=\"sr-only\">(current)</span></a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=2\">2</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=3\">3</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=4\">4</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=5\">5</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=6\">6</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=7\">7</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=8\">8</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=9\">9</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=10\">10</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=2\" rel=\"next\" aria-label=\"Next\">" +
                            "<span aria-hidden=\"true\">»</span>" +
                            "<span class=\"sr-only\">Next</span>" +
                        "</a>" +
                    "</li>\n" +
                "</ul>\n" +
            "</nav>"
        
        XCTAssertEqual(bytes.string, expectedHTML)
    }
    
    func testNoNextPageWithBootstrap3() {
        let tag = PaginatorTag(useBootstrap4: false, paginationLabel: "Some Pages")
        let paginator = buildPaginator(currentPage: 10)
        
        let result = expectNoThrow() {
            return try run(
                tag: tag,
                context: paginator,
                arguments: [.variable(path: [], value: paginator)]
            )
            }!
        
        guard result != nil, case .bytes(let bytes) = result! else {
            XCTFail("Should have returned bytes")
            return
        }
        
        let expectedHTML =
            "<nav class=\"paginator text-center\" aria-label=\"Some Pages\">\n" +
                "<ul class=\"pagination\">\n" +
                    "<li>" +
                        "<a href=\"?page=9\" rel=\"prev\" aria-label=\"Previous\">" +
                            "<span aria-hidden=\"true\">«</span>" +
                            "<span class=\"sr-only\">Previous</span>" +
                        "</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=1\">1</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=2\">2</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=3\">3</a>" +
                    "</li>\n" +
                    "<li>" +
                    "<a href=\"?page=4\">4</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=5\">5</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=6\">6</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=7\">7</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=8\">8</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=9\">9</a>" +
                    "</li>\n" +
                    "<li class=\"active\">" +
                        "<a>" +
                            "<span>10</span>" +
                            "<span class=\"sr-only\">(current)</span>" +
                        "</a>" +
                    "</li>\n" +
                    "<li class=\"disabled\">" +
                        "<a>" +
                            "<span aria-label=\"Next\" aria-hidden=\"true\">»</span>" +
                            "<span class=\"sr-only\">Next</span>" +
                        "</a>" +
                    "</li>\n" +
                "</ul>\n" +
            "</nav>"
        
        XCTAssertEqual(bytes.string, expectedHTML)
    }
    
    func testNoPreviousPageWithBootstrap4() {
        let tag = PaginatorTag(useBootstrap4: true, paginationLabel: "Some Pages")
        let paginator = buildPaginator(currentPage: 1)
        
        let result = expectNoThrow() {
            return try run(
                tag: tag,
                context: paginator,
                arguments: [.variable(path: [], value: paginator)]
            )
        }!
        
        guard result != nil, case .bytes(let bytes) = result! else {
            XCTFail("Should have returned bytes")
            return
        }
        
        let expectedHTML =
            "<nav class=\"paginator\" aria-label=\"Some Pages\">\n" +
                "<ul class=\"pagination justify-content-center\">\n" +
                    "<li class=\"disabled page-item\">" +
                        "<a>" +
                            "<span class=\"page-link\" aria-label=\"Previous\" aria-hidden=\"true\">«</span>" +
                            "<span class=\"sr-only\">Previous</span>" +
                        "</a>" +
                    "</li>\n" +
                    "<li class=\"active page-item\">" +
                        "<a>" +
                            "<span class=\"page-link\">1</span>" +
                            "<span class=\"sr-only\">(current)</span>" +
                        "</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=2\" class=\"page-link\">2</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=3\" class=\"page-link\">3</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=4\" class=\"page-link\">4</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=5\" class=\"page-link\">5</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=6\" class=\"page-link\">6</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=7\" class=\"page-link\">7</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=8\" class=\"page-link\">8</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=9\" class=\"page-link\">9</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=10\" class=\"page-link\">10</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=2\" class=\"page-link\" rel=\"next\" aria-label=\"Next\">" +
                            "<span aria-hidden=\"true\">»</span>" +
                            "<span class=\"sr-only\">Next</span>" +
                        "</a>" +
                    "</li>\n" +
                "</ul>\n" +
            "</nav>"
        
        XCTAssertEqual(bytes.string, expectedHTML)
    }
    
    func testNoNextPageWithBootstrap4() {
        let tag = PaginatorTag(useBootstrap4: true, paginationLabel: "Some Pages")
        let paginator = buildPaginator(currentPage: 10)
        
        let result = expectNoThrow() {
            return try run(
                tag: tag,
                context: paginator,
                arguments: [.variable(path: [], value: paginator)]
            )
            }!
        
        guard result != nil, case .bytes(let bytes) = result! else {
            XCTFail("Should have returned bytes")
            return
        }
        
        let expectedHTML =
            "<nav class=\"paginator\" aria-label=\"Some Pages\">\n" +
                "<ul class=\"pagination justify-content-center\">\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=9\" class=\"page-link\" rel=\"prev\" aria-label=\"Previous\">" +
                            "<span aria-hidden=\"true\">«</span>" +
                            "<span class=\"sr-only\">Previous</span>" +
                        "</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=1\" class=\"page-link\">1</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=2\" class=\"page-link\">2</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=3\" class=\"page-link\">3</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=4\" class=\"page-link\">4</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=5\" class=\"page-link\">5</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=6\" class=\"page-link\">6</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=7\" class=\"page-link\">7</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=8\" class=\"page-link\">8</a>" +
                    "</li>\n" +
                    "<li class=\"page-item\">" +
                        "<a href=\"?page=9\" class=\"page-link\">9</a>" +
                    "</li>\n" +
                    "<li class=\"active page-item\">" +
                        "<a>" +
                            "<span class=\"page-link\">10</span>" +
                            "<span class=\"sr-only\">(current)</span>" +
                        "</a>" +
                    "</li>\n" +
                    "<li class=\"disabled page-item\">" +
                        "<a>" +
                            "<span class=\"page-link\" aria-label=\"Next\" aria-hidden=\"true\">»</span>" +
                            "<span class=\"sr-only\">Next</span>" +
                        "</a>" +
                    "</li>\n" +
                "</ul>\n" +
            "</nav>"
        
        XCTAssertEqual(bytes.string, expectedHTML)
    }

    func testRunTagWithQueryParams() {
        let tag = PaginatorTag()
        let paginator = buildPaginator(query: ["foo": "bar"])

        let result = expectNoThrow() {
            return try run(
                tag: tag,
                context: paginator,
                arguments: [
                    .variable(path: [], value: paginator)
                ]
            )

        }!

        guard result != nil, case .bytes(let bytes) = result! else {
            XCTFail("Should have returned bytes")
            return
        }

        let expectedHTML =
            "<nav class=\"paginator text-center\">\n" +
                "<ul class=\"pagination\">\n" +
                    "<li>" +
                        "<a href=\"?page=1&foo=bar\" rel=\"prev\" aria-label=\"Previous\">" +
                            "<span aria-hidden=\"true\">«</span><span class=\"sr-only\">Previous</span>" +
                        "</a>" +
                    "</li>\n" +
                    "<li><a href=\"?page=1&foo=bar\">1</a></li>\n" +
                    "<li class=\"active\"><a>" +
                        "<span>2</span><span class=\"sr-only\">(current)</span></a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=3&foo=bar\">3</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=4&foo=bar\">4</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=5&foo=bar\">5</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=6&foo=bar\">6</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=7&foo=bar\">7</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=8&foo=bar\">8</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=9&foo=bar\">9</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=10&foo=bar\">10</a>" +
                    "</li>\n" +
                    "<li>" +
                        "<a href=\"?page=3&foo=bar\" rel=\"next\" aria-label=\"Next\">" +
                            "<span aria-hidden=\"true\">»</span>" +
                            "<span class=\"sr-only\">Next</span>" +
                        "</a>" +
                    "</li>\n" +
                "</ul>\n" +
            "</nav>"

        XCTAssertEqual(bytes.string, expectedHTML)
    }
    
    func testRunTagFailedTwoArgs() {
        let tag = PaginatorTag()
        
        expect(toThrow: PaginatorTag.Error.expectedOneArgument(got: 0)) {
            let _ = try run(
                tag: tag,
                context: .null,
                arguments: [
                ]
            )
        }
    }
}

extension LeafTests {
    func buildPaginator(currentPage: Int = 2, query: Node = Node([:])) -> Node {
        var linksNode = Node([:])
        var queryNode = query

        func addToLinksNode(key: String, page: Int) {
            queryNode["page"] = try! page.makeNode()
            let path = PaginatorHelper.buildPath(
                page: page,
                count: 10,
                uriQueries: query
            )
            linksNode[key] = path!.makeNode()
        }

        if currentPage > 1 {
            addToLinksNode(key: "previous", page: currentPage - 1)
        }

        if currentPage < 10 {
            addToLinksNode(key: "next", page: currentPage + 1)
        }

        return Node([
            "meta": Node([
                "paginator": Node([
                    "current_page": try! currentPage.makeNode(),
                    "total_pages": 10,
                    "queries": queryNode,
                    "links": linksNode
                ])
            ])
        ])
    }
    
    func run(tag: Tag, context node: Node, arguments: [Argument]) throws -> Node? {
        let context = Context(node)
        
        return try tag.run(
            stem: Stem(workingDirectory: ""),
            context: context,
            tagTemplate: TagTemplate(name: "", parameters: [], body: nil),
            arguments: arguments
        )
    }
}
