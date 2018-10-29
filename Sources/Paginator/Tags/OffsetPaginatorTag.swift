import Sugar
import TemplateKit

public final class OffsetPaginatorTag: TagRenderer {
    let c: (TagContext, OffsetPaginatorControlData) throws -> Future<TemplateData>

    public init(templatePath: String) {
        c = { tag, inputData in
            try tag.requireNoBody()
            return try tag
                .container
                .make(TemplateRenderer.self)
                .render(templatePath, inputData)
                .map { .data($0.data) }
        }
    }

    public func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        try tag.requireNoBody()
        let controlData = try tag.requireOffsetPaginatorControlData()
        return try c(tag, controlData)
    }
}
