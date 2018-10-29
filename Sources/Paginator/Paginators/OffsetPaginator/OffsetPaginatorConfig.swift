import Vapor

public struct OffsetPaginatorConfig: Service {
    public let perPage: Int
    public let defaultPage: Int

    public init(perPage: Int, defaultPage: Int) {
        self.perPage = perPage
        self.defaultPage = defaultPage
    }
}

extension OffsetPaginatorConfig {
    public static var `default`: OffsetPaginatorConfig {
        return .init(perPage: 25, defaultPage: 1)
    }
}
