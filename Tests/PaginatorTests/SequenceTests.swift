import XCTest

import HTTP
import Fluent
import Foundation

@testable import Paginator

class SequenceTests: XCTestCase {
    static var allTests = [
        ("testBasic", testBasic),
        ("testAddingQueries", testAddingQueries),
        ("testMakeNode", testMakeNode),
        ]
    
    override func setUp() {
        Database.default = Database(TestDriver())
    }
    
    func testBasic() {
        let request = Request(method: .get, uri: "/users?page=2")
        
        //TODO(Brett): add `expect` tools
        let paginator = try! TestUserEntity.all().paginator(2, request: request)
        
        XCTAssertEqual(paginator.baseURI.path, "/users")
        
        XCTAssertEqual(paginator.perPage, 2)
        XCTAssertEqual(paginator.currentPage, 2)
        
        XCTAssertEqual(paginator.pageName, "page")
        XCTAssertEqual(paginator.dataKey, "data")
        
        XCTAssertNotNil(paginator.previousPage)
        let previousPageComponents = URLComponents(string: paginator.previousPage!)
        let previousPagePath = previousPageComponents?.path
        let previousPageQuery = previousPageComponents?.query
        let expectedPreviousPageQueryNode = try! Node(node: "page=1&count=2".bytes)
        let actualPreviousPageQueryNode = try! Node(node: previousPageQuery!.bytes)
        XCTAssertEqual(expectedPreviousPageQueryNode, actualPreviousPageQueryNode)
        XCTAssertEqual(previousPagePath, "/users")
        
        XCTAssertNotNil(paginator.nextPage)
        let nextPageComponents = URLComponents(string: paginator.nextPage!)
        let nextPagePath = nextPageComponents?.path
        let nextPageQuery = nextPageComponents?.query
        let expectedNextPageQueryNode = try! Node(node: "page=3&count=2".bytes)
        let actualNextPageQueryNode = try! Node(node: nextPageQuery!.bytes)
        XCTAssertEqual(expectedNextPageQueryNode, actualNextPageQueryNode)
        XCTAssertEqual(nextPagePath, "/users")
        
        XCTAssertEqual(paginator.totalPages, 3)
        
        XCTAssertNotNil(paginator.total)
        XCTAssertEqual(paginator.total, 6)
    }
    
    func testAddingQueries() {
        let request = Request(method: .get, uri: "/users")
        
        //TODO(Brett): add `expect` tools
        let paginator = try! TestUserEntity.all().paginator(
            2,
            request: request.addingValues(["search": "Brett"])
        )
        XCTAssertNil(paginator.previousPage)
        XCTAssertNotNil(paginator.nextPage)
        
        let components = URLComponents(string: "/users?count=2&search=Brett&page=2")
        let query = components?.query
        let path = components?.path
        
        let queryNode = try! Node(node: query!.bytes)
        let expectedQueryNode = try! Node(node: "count=2&search=Brett&page=2".bytes)
        
        XCTAssertEqual(queryNode, expectedQueryNode)
        XCTAssertEqual(path, "/users")
    }
    
    func testMakeNode() {
        let request = Request(method: .get, uri: "/users")
        let paginator = try! TestUserEntity.all().paginator(4, request: request)
        
        //TODO(Brett): add `expect` tools
        let node = try! paginator.makeNode(in: nil)
        
        XCTAssertNotNil(node["data"])
        
        guard let paginatorNode = node["meta", "paginator"]?.object else {
            XCTFail("should have a paginator node.")
            return
        }
        
        let nodesToTest = [
            ("total", 6),
            ("current_page", 1),
            ("total_pages", 2),
            ("per_page", 4)
        ]
        
        nodesToTest.forEach { key, expected in
            XCTAssertEqual(paginatorNode[key]?.int, expected)
        }
        
        guard let links = paginatorNode["links"]?.object else {
            XCTFail("paginator should contain a links object.")
            return
        }
        
        XCTAssertNil(links["previous"]?.string)
        
        let actualNextPathComponents = URLComponents(string: (links["next"]?.string)!)
        let expectedQueryNode = Node(formURLEncoded: "page=2&count=4".bytes, allowEmptyValues: true)
        var actualQueryNode = Node(formURLEncoded: actualNextPathComponents!.query!.bytes, allowEmptyValues: true)

        expectedQueryNode.object?.forEach {
            XCTAssertEqual($0.value, actualQueryNode[$0.key])
            actualQueryNode.removeKey($0.key)
        }

        XCTAssertEqual(actualQueryNode.object?.count, 0, "Expected object to be empty")
        XCTAssertEqual(actualNextPathComponents?.path, "/users")
    }
    
}

