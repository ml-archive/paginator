import TemplateKit

/*
Intended behaviour of the offset paginator tag:
< 1 >
< 1 2 >
< 1 2 3 >
< 1 2 3 4 >
< 1 2 3 4 5 >
< 1 2 3 4 5 6 >
< 1 2 3 4 5 6 7 >
< 1 2 3 4 5 6 7 8 >
< 1 2 3 4 5 6 7 8 9 >
< 1 2 3 4 5 6 7 ... 10 >
< 1 ... 3 4 5 6 7 ... 10 >
< 1 ... 4 5 6 7 8 9 10 >

< = previous
> = next
first = 1
last = 10
left = ... (left side)
right = ... (right side)
middle = 3 4 5 6 7
*/

public struct OffsetPaginatorControlData: Codable {
    private struct Control: Codable {
        let url: String
        let page: Int
    }

    private let current: Control
    private let previous: Control?
    private let next: Control?
    private let first: Control
    private let last: Control?
    private let left: Bool
    private let right: Bool
    private let middle: [Control]

    init(metaData: OffsetMetaData) throws {
        current = Control(url: metaData.url.absoluteString, page: metaData.currentPage)
        previous = metaData.links.previous.map { Control(url: $0, page: metaData.currentPage - 1) }
        next = metaData.links.next.map { Control(url: $0, page: metaData.currentPage + 1) }
        first = Control(url: try metaData.link(for: 1), page: 1)

        let check = try metaData.link(for: metaData.totalPages)
        last = first.url == check ? nil : Control(url: check, page: metaData.totalPages)

        let showDots = metaData.totalPages > 9
        left = showDots && metaData.currentPage >= 5
        right = showDots && metaData.currentPage <= metaData.totalPages - 5

        var middle: [Control]
        if metaData.totalPages > 2 {
            let bounds = OffsetPaginatorControlData.bounds(
                left: left,
                right: right,
                current: metaData.currentPage,
                total: metaData.totalPages
            )

            let range: CountableClosedRange = bounds.lower...bounds.upper
            let middleLinks = try metaData.links(in: range)
            middle = zip(range, middleLinks).map { (page, url) in
                Control(url: url, page: page)
            }
        } else {
            middle = []
        }
        self.middle = middle
    }

    private static func bounds(
        left: Bool,
        right: Bool,
        current: Int,
        total: Int
    ) -> (lower: Int, upper: Int) {
        switch (left, right) {
        case (false, false): return (min(total, 2), total - 1)
        case (false, true): return (2, min(7, total))
        case (true, true): return (current - 2, current + 2)
        case (true, false): return (max(1, total - 6), total - 1)
        }
    }
}

private let userInfoKey = "offsetPaginatorControlData"

public enum TagContextPaginatorError: Error {
    case paginatorNotPassedInToRender
    case paginatorDoesNotContainMetaData
}

public extension OffsetPaginator {
    public func userInfo() throws -> [AnyHashable: Any] {
        guard let metaData = self.metaData() else {
            throw TagContextPaginatorError.paginatorDoesNotContainMetaData
        }

        return [userInfoKey: try OffsetPaginatorControlData(metaData: metaData)]
    }
}

public extension TagContext {
    public func requireOffsetPaginatorControlData() throws -> OffsetPaginatorControlData {
        guard
            let metaData = self.context.userInfo[userInfoKey] as? OffsetPaginatorControlData
        else {
            throw TagContextPaginatorError.paginatorNotPassedInToRender
        }

        return metaData
    }
}
