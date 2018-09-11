import Authentication
import Leaf
import Sugar
import TemplateKit

public final class OffsetPaginatorTag: TagRenderer {
    public func render(tag: TagContext) throws -> Future<TemplateData> {
        try tag.requireParameterCount(1)

        guard
            let object = tag.parameters.first?.dictionary
        else {
            throw tag.error(reason: "Please pass in meta")
        }


        return tag.future(.string("TODO2"))
    }
}
