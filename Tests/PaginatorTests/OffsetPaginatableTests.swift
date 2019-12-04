import XCTest
import Vapor
@testable import Paginator

class OffsetPaginatableTests: XCTestCase {
    struct PaginateableData: Codable {
        let id: Int
        let name: String
        let createdAt: Date
    }

    var paginatable: [PaginateableData] = []
    var parameters: OffsetParameters = OffsetParameters(page: 1, perPage: 1)
    var url: URL = URL(string: "https://www.google.com")!

    override func setUp() {
        super.setUp()

        self.paginatable = [
            PaginateableData(id: 1, name: "lorem", createdAt: Date()),
            PaginateableData(id: 2, name: "ipsum", createdAt: Date()),
            PaginateableData(id: 3, name: "dolor", createdAt: Date()),
            PaginateableData(id: 4, name: "sit", createdAt: Date()),
            PaginateableData(id: 5, name: "consectetur", createdAt: Date()),
            PaginateableData(id: 6, name: "adipiscing", createdAt: Date()),
            PaginateableData(id: 7, name: "elit", createdAt: Date()),
            PaginateableData(id: 8, name: "Sed", createdAt: Date()),
            PaginateableData(id: 9, name: "nec", createdAt: Date()),
            PaginateableData(id: 10, name: "mauris", createdAt: Date())
        ]

        self.parameters = OffsetParameters(page: 1, perPage: 1)
        self.url = URL(string: "https://www.google.com")!
    }

    override func tearDown() {
        super.tearDown()

        self.paginatable = []
        self.parameters = OffsetParameters(page: 1, perPage: 1)
        self.url = URL(string: "https://www.google.com")!
    }

    func testPaginateNoTransformer() throws {
        let eventLoop = EmbeddedEventLoop()
        let offsetPaginator = eventLoop.future(paginatable)

        let paginator = try offsetPaginator.paginate(parameters: parameters, url: url).wait()

        XCTAssertEqual(paginator.data.count, self.parameters.perPage)
        XCTAssertEqual(paginator.metadata.currentPage, self.parameters.page)
        XCTAssertEqual(paginator.data.first?.id, self.paginatable.first?.id)
        XCTAssertNotNil(paginator.data.first)
    }

    func testPaginateWithTransformer() throws {
        let eventLoop = EmbeddedEventLoop()
        let offsetPaginator = eventLoop.future(paginatable)

        let paginator = try offsetPaginator.paginate(
            parameters: parameters,
            url: url,
            transformer: .init()
        ).wait()

        XCTAssertEqual(paginator.data.count, self.parameters.perPage)
        XCTAssertEqual(paginator.metadata.currentPage, self.parameters.page)
        XCTAssertEqual(paginator.data.first?.id, self.paginatable.first?.id)
        XCTAssertNotNil(paginator.data.first)
    }

    func testPaginateNoTransformerPageTwo() throws {
        self.parameters = OffsetParameters(page: 2, perPage: 2)
        let eventLoop = EmbeddedEventLoop()
        let offsetPaginator = eventLoop.future(paginatable)

        let paginator = try offsetPaginator.paginate(parameters: parameters, url: url).wait()

        XCTAssertEqual(paginator.data.count, self.parameters.perPage)
        XCTAssertEqual(paginator.metadata.currentPage, self.parameters.page)
        XCTAssertEqual(paginator.data.first?.id, self.paginatable[2].id)
        XCTAssertNotNil(paginator.data.first)
    }

    func testPaginateNoTransformerPageThree() throws {
        self.parameters = OffsetParameters(page: 3, perPage: 2)
        let eventLoop = EmbeddedEventLoop()
        let offsetPaginator = eventLoop.future(paginatable)

        let paginator = try offsetPaginator.paginate(parameters: parameters, url: url).wait()

        XCTAssertEqual(paginator.data.count, self.parameters.perPage)
        XCTAssertEqual(paginator.metadata.currentPage, self.parameters.page)
        XCTAssertEqual(paginator.data.first?.id, self.paginatable[4].id)
        XCTAssertNotNil(paginator.data.first)
    }

    func testPaginateNoTransformerPageFour() throws {
        self.parameters = OffsetParameters(page: 4, perPage: 2)
        let eventLoop = EmbeddedEventLoop()
        let offsetPaginator = eventLoop.future(paginatable)

        let paginator = try offsetPaginator.paginate(parameters: parameters, url: url).wait()

        XCTAssertEqual(paginator.data.count, self.parameters.perPage)
        XCTAssertEqual(paginator.metadata.currentPage, self.parameters.page)
        XCTAssertEqual(paginator.data.first?.id, self.paginatable[6].id)
        XCTAssertNotNil(paginator.data.first)
    }

    func testPaginateNoTransformerPageFive() throws {
        self.parameters = OffsetParameters(page: 5, perPage: 2)
        let eventLoop = EmbeddedEventLoop()
        let offsetPaginator = eventLoop.future(paginatable)

        let paginator = try offsetPaginator.paginate(parameters: parameters, url: url).wait()

        XCTAssertEqual(paginator.data.count, self.parameters.perPage)
        XCTAssertEqual(paginator.metadata.currentPage, self.parameters.page)
        XCTAssertEqual(paginator.data.first?.id, self.paginatable[8].id)
        XCTAssertNotNil(paginator.data.first)
    }

    func testPaginateNoTransformerInvalidPageSix() throws {
        self.parameters = OffsetParameters(page: 5, perPage: 2)
        let eventLoop = EmbeddedEventLoop()
        let offsetPaginator = eventLoop.future(paginatable)

        let paginator = try offsetPaginator.paginate(parameters: parameters, url: url).wait()

        XCTAssertEqual(paginator.data.count, self.parameters.perPage)
        XCTAssertEqual(paginator.metadata.currentPage, self.parameters.page)
        XCTAssertEqual(paginator.data.first?.id, self.paginatable[8].id)
        XCTAssertNotNil(paginator.data.first)
    }

    func testPaginateParametersWithRequest() throws {
        let eventLoop = EmbeddedEventLoop()

        let container = BasicContainer.init(
            config: .default(),
            environment: .testing,
            services: .default(),
            on: eventLoop
        )

        let request = Request(using: container)
        let parameters = try request.offsetParameters().wait()

        XCTAssertEqual(parameters.page, OffsetPaginatorConfig.default.defaultPage)
        XCTAssertEqual(parameters.perPage, OffsetPaginatorConfig.default.perPage)
    }

    func testPaginateWithRequest() throws {
        let requestParamPage = 1
        let requestParamPerPage = 5
        let eventLoop = EmbeddedEventLoop()

        let container = BasicContainer.init(
            config: .default(),
            environment: .testing,
            services: .default(),
            on: eventLoop
        )

        let request = Request(using: container)
        request.http.url = URL(
            string: "/?page=\(requestParamPage)&perPage=\(requestParamPerPage)"
        )!
        let offsetPaginator = eventLoop.future(paginatable)

        let paginator = try offsetPaginator.paginate(on: request).wait()
        XCTAssertEqual(paginator.data.count, requestParamPerPage)
        XCTAssertEqual(paginator.metadata.currentPage, requestParamPage)
        XCTAssertEqual(paginator.metadata.perPage, requestParamPerPage)
    }
}
