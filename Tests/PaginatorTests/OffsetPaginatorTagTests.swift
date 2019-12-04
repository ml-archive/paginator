import XCTest
import Vapor
@testable import Paginator

class OffsetPaginatorTagTests: XCTestCase {
    func testTagRendering() throws {
        let eventLoop = EmbeddedEventLoop()
        let container = BasicContainer(
            config: .default(),
            environment: .testing,
            services: .default(),
            on: eventLoop
        )

        let path = "Paginator/offsetpaginator.leaf"
        let context = try getTagContext(on: container)
        let tag = OffsetPaginatorTag(templatePath: path)
        let templateData = try tag.render(tag: context).wait()

        XCTAssertEqual(templateData, TemplateData.string("lol"))
    }

    private func getTemplateSource() -> TemplateSource {
        return TemplateSource(file: "", line: 0, column: 0, range: 0..<10)
    }

    private func getTemplateDataContext() throws -> TemplateDataContext {
        let context = TemplateDataContext(data: .string("testing"))
        context.userInfo = [
            "offsetPaginatorControlData" : try self.getControlData()
        ]

        return context
    }

    private func getSerializer(on container: Container) throws -> TemplateSerializer {
        return TemplateSerializer(
            renderer: try container.make(PlaintextRenderer.self),// PlaintextRenderer(viewsDir: "/Resources/Views", on: container),
            context: try getTemplateDataContext(),
            using: container
        )
    }

    private func getTagContext(on container: Container) throws -> TagContext {
        let context = TagContext(
            name: "",
            parameters: [],
            body: nil,
            source: self.getTemplateSource(),
            context: try self.getTemplateDataContext(),
            serializer: try self.getSerializer(on: container),
            using: container
        )

        return context
    }

    private func getControlData() throws -> OffsetPaginatorControlData {
        let total = 100
        let url = URL(string: "https://www.google.com")!
        let parameters = OffsetParameters.init(
            page: OffsetPaginatorConfig.default.defaultPage,
            perPage: OffsetPaginatorConfig.default.perPage
        )
        let metadata = try OffsetMetadata(parameters: parameters, total: total, url: url)
        return try OffsetPaginatorControlData(metadata: metadata)
    }
}
