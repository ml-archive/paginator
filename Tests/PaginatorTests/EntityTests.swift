import XCTest

import HTTP
import Fluent

@testable import Paginator

class EntityTest: XCTestCase {
    static var allTests = [
        ("testBasic", testBasic),
        ("testMakeNode", testMakeNode)
    ]
    
    override func setUp() {
        Database.default = Database(TestDriver())
    }
    
    func testBasic() {
        let request = try! Request(method: .get, uri: "http://localhost/users?page=2")
        
        //TODO(Brett): add `expect` tools
        let paginator = try! TestUserEntity.paginator(2, request: request)
        
        XCTAssertEqual(paginator.baseURI.path, "/users")
        
        XCTAssertEqual(paginator.perPage, 2)
        XCTAssertEqual(paginator.currentPage, 2)
        
        XCTAssertEqual(paginator.pageName, "page")
        XCTAssertEqual(paginator.dataKey, "data")
        
        XCTAssertNotNil(paginator.previousPage)
        XCTAssertEqual(paginator.previousPage, "/users?page=1&count=2")
        XCTAssertNotNil(paginator.nextPage)
        XCTAssertEqual(paginator.nextPage, "/users?page=3&count=2")
        
        XCTAssertEqual(paginator.totalPages, 3)
        
        XCTAssertNotNil(paginator.total)
        XCTAssertEqual(paginator.total, 6)
    }
    
    
    
    func testMakeNode() {
        let request = try! Request(method: .get, uri: "http://localhost/users")
        let paginator = try! TestUserEntity.paginator(4, request: request)
        
        //TODO(Brett): add `expect` tools
        let node = try! paginator.makeNode()
        
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
        XCTAssertEqual(links["next"]?.string, "/users?page=2&count=4")
    }
}

class TestDriver: Driver {
    var idKey: String = "id"
    
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
            return try entitiesNode.makeNode()
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

struct TestUserEntity: Entity {
    var id: Node?
    
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        age = try node.extract("age")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "age": age
        ])
    }
    
    static func prepare(_ database: Database) throws {}
    static func revert(_ database: Database) throws {}
}
