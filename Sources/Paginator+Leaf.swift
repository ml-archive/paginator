import Core
import Leaf

public final class PaginatorTag: Tag {
    public enum Error: Swift.Error {
        case expectedOneArgument(got: Int)
        case expectedVariable
        case expectedValidPaginator
    }
    
    public let name = "paginator"
    
    public func run(
        stem: Stem,
        context: Context,
        tagTemplate: TagTemplate,
        arguments: [Argument]
    ) throws -> Node? {
        guard
            arguments.count == 1,
            let argument = arguments.first
        else {
                throw Error.expectedOneArgument(got: arguments.count)
        }
        
        guard case .variable(_, let value) = argument else {
            throw Error.expectedVariable
        }
        
        guard let paginator = value?["meta", "paginator"]?.object else {
            throw Error.expectedValidPaginator
        }
        
        guard
            let currentPage = paginator["current_page"]?.int,
            let totalPages = paginator["total_pages"]?.int,
            let links = paginator["links"]?.object
        else {
                return nil
        }
        
        return buildNavigation(currentPage: currentPage, totalPages: totalPages, links: links)
    }
    
    public func shouldRender(
        stem: Stem,
        context: Context,
        tagTemplate: TagTemplate,
        arguments: [Argument],
        value: Node?
    ) -> Bool {
        return true
    }
}

extension PaginatorTag {
    func buildBackButton(url: String?) -> Bytes {
        guard let url = url else {
            return "<li class=\"disabled\"><span>«</span></li>\n".bytes
        }

        return "<li><a href=\"\(url)\" rel=\"prev\">«</a></li>\n".bytes
    }
    
    func buildForwardButton(url: String?) -> Bytes {
        guard let url = url else {
            return "<li class=\"disabled\"><span>»</span></li>\n".bytes
        }
        
        return "<li><a href=\"\(url)\" rel=\"next\">»</a></li>\n".bytes
    }
    
    func buildLinks(currentPage: Int, count: Int) -> Bytes {
        var bytes: Bytes = []
        
        for i in 1...count {
            if i == currentPage {
                bytes += "<li class=\"active\"><span>\(i)</span></li>\n".bytes
            } else {
                bytes += "<li><a href=\"?page=\(i)\">\(i)</a></li>\n".bytes
            }
        }
        
        return bytes
    }
    
    func buildNavigation(currentPage: Int, totalPages: Int, links: [String : Polymorphic]) -> Node {
        var bytes: Bytes = []
        
        let header = "<nav class=\"paginator text-center\">\n<ul class=\"pagination\">\n".bytes
        let footer = "</ul>\n</nav>".bytes
        
        bytes += header
        
        bytes += buildBackButton(url: links["previous"]?.string)
        
        bytes += buildLinks(currentPage: currentPage, count: totalPages)
        
        bytes += buildForwardButton(url: links["next"]?.string)
        
        bytes += footer
        
        return .bytes(bytes)
    }
}
