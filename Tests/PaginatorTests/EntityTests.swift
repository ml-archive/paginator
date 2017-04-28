import XCTest

import HTTP
import FluentProvider
import Foundation

@testable import Paginator

class EntityTest: XCTestCase {
    static var allTests = [
        ("testBasic", testBasic),
        ("testAddingQueries", testAddingQueries),
        ("testMakeNode", testMakeNode),
        ("testEntityQueryExtension", testEntityQueryExtension),
    ]
    
    override func setUp() {
        Database.default = Database(TestDriver())
    }
    
    func testBasic() {
        let request = try! Request(method: .get, uri: "/users?page=2")
        
        //TODO(Brett): add `expect` tools
        let paginator = try! TestUserEntity.paginator(2, request: request)
        
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
        let request = try! Request(method: .get, uri: "/users")
        
        //TODO(Brett): add `expect` tools
        let paginator = try! TestUserEntity.paginator(
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
        let request = try! Request(method: .get, uri: "/users")
        let paginator = try! TestUserEntity.paginator(4, request: request)
        
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
        let expectedQueryNode = try! Node(node: "page=2&count=4".bytes)
        let actualQueryNode = try! Node(node: actualNextPathComponents!.query!.bytes)
        XCTAssertEqual(expectedQueryNode, actualQueryNode)
        XCTAssertEqual(actualNextPathComponents?.path, "/users")
    }
    
    func testEntityQueryExtension() {
        
    }
}

class TestDriver: Driver {
    var idKey: String = "id"
    var idType: IdentifierType = .custom("my-type")
    var keyNamingConvention: KeyNamingConvention = .camelCase
    var queryLogger: QueryLogger? = nil


    func makeConnection(_ type: ConnectionType) throws -> Connection {
        return TestConnection()
    }

    func query<T : Entity>(_ query: Query<T>) throws -> Node {
        let entities = [
            ("John", 1),
            ("Ye-Sol", 2),
            ("Timmy", 3),
            ("MacFree", 4),
            ("Zed", 5),
            ("Glenn", 6)
        ]
        
        let entityCount = entities.count
        
        let entitiesNode = entities.map { (name, id) in
            Node.object([
                "id": .number(.int(id)),
                "name": .string(name),
                "age": .number(.int(id * 10))
            ])
        }
        
        switch query.action {
        case .count:
            return .number(.int(entityCount))
            
        case .fetch:
            return try entitiesNode.makeNode(in: nil)
        default:
            return nil
        }
    }
    
    func schema(_ schema: Schema) throws {}
    
    @discardableResult
    public func raw(_ query: String, _ values: [Node] = []) throws -> Node {
        return .null
    }
}

final class TestUserEntity: Entity, NodeConvertible {
    var id: Node?
    
    var name: String
    var age: Int

    let storage = Storage()

    init(row: Row) throws {
        id = try row.get("id")
        name = try row.get("name")
        age = try row.get("age")
    }

    func makeRow() throws -> Row {
        return Row()
    }

    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    init(node: Node) throws {
        id = try node.get("id")
        name = try node.get("name")
        age = try node.get("age")
    }
    
    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            "id": id as Any,
            "name": name,
            "age": age
        ])
    }
    
    static func prepare(_ database: Database) throws {}
    static func revert(_ database: Database) throws {}
}

class TestConnection: Connection {
    var queryLogger: QueryLogger?
    var isClosed: Bool = false
    public func query<E: Entity>(_ query: RawOr<Query<E>>) throws -> Node {
        let entities = [
            ("John", 1),
            ("Ye-Sol", 2),
            ("Timmy", 3),
            ("MacFree", 4),
            ("Zed", 5),
            ("Glenn", 6)
        ]

        let entityCount = entities.count

        let entitiesNode = entities.map { (name, id) in
            Node.object([
                "id": .number(.int(id)),
                "name": .string(name),
                "age": .number(.int(id * 10))
                ])
        }

        switch query.wrapped!.action {
        case .count:
            return .number(.int(entityCount))

        case .fetch:
            return Node(entitiesNode)
        default:
            return nil
        }







//        switch query.wrapped!.action {
//        case .fetch:
//            return Node.array([Node.object([
//                "id": 1,
//                "name": "Jimmy",
//                "age": 13
//                ])])
//
//        case .count:
//            return Node.array([
//                Node.object(["_fluent_count": 1])
//            ])
//
//        default:
//            return nil
//        }
    }
}
