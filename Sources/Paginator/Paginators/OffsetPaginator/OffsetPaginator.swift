import Vapor

public struct OffsetPaginator<Object: Codable>: Content {
    public typealias PaginatorMetadata = OffsetMetadata

    public let data: [Object]
    public let metadata: OffsetMetadata

    public init(data: [Object], metadata: OffsetMetadata) {
        self.data = data
        self.metadata = metadata
    }
}

public extension OffsetPaginator {
    typealias ResultObject = Object
    typealias PaginatableMetadata = OffsetMetadata
}

public enum OffsetMetadataError: Error {
    case invalidParameters
}

public struct OffsetMetadata: Codable {
    struct Links: Codable {
        let previous: String?
        let next: String?
    }

    internal let url: URL
    public let currentPage: Int
    public let perPage: Int
    public let total: Int
    public let totalPages: Int
    let links: Links

    public init(parameters: OffsetParameters, total: Int, url: URL) throws {
        self.url = url
        self.perPage = parameters.perPage
        self.total = total

        self.totalPages = max(1, Int(ceil(Double(total) / Double(perPage))))
        self.currentPage = min(parameters.page, totalPages)

        let nav = try OffsetMetadata.nextAndPreviousLinks(
            currentPage: self.currentPage,
            totalPages: self.totalPages,
            url: self.url
        )

        self.links = Links(previous: nav.previous, next: nav.next)
    }
}

public struct OffsetQueryParameters: Decodable, Reflectable {
    public let perPage: Int?
    public let page: Int?
}

public struct OffsetParameters {
    public let page: Int
    public let perPage: Int

    public init(page: Int, perPage: Int) {
        self.page = max(1, page)
        self.perPage = max(1, perPage)
    }

    public init(config: OffsetPaginatorConfig, queryParameters: OffsetQueryParameters) {
        let page = queryParameters.page ?? config.defaultPage
        let perPage = queryParameters.perPage ?? config.perPage

        self.init(page: page, perPage: perPage)
    }
}

extension OffsetParameters {
    public var range: Range<Int> {
        let lower = (page - 1) * perPage
        return lower..<(lower + perPage)
    }
}
