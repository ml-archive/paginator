import TemplateKit

public final class OffsetPaginatorTag: TagRenderer {
    let render: (TagContext, OffsetPaginatorControlData) throws -> Future<TemplateData>

    public init(templatePath: String) {
        render = { tag, inputData in
            try tag.requireNoBody()
            return try tag
                .container
                .make(TemplateRenderer.self)
                .render(templatePath, inputData)
                .map { .data($0.data) }
        }
    }

    public func render(tag: TagContext) throws -> Future<TemplateData> {
        try tag.requireNoBody()
        let controlData = try tag.requireOffsetPaginatorControlData()
        return try render(tag, controlData)
    }
}
