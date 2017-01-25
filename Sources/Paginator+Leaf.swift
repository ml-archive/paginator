import Core
import Leaf

public final class PaginatorTag: Tag {
    public enum Error: Swift.Error {
        case expectedOneArgument(got: Int)
        case expectedVariable
        case expectedValidPaginator
    }
    
    fileprivate let useBootstrap4: Bool
    fileprivate let paginationLabel: String?
    
    public init(useBootstrap4: Bool = false, paginationLabel: String? = nil) {
        self.useBootstrap4 = useBootstrap4
        self.paginationLabel = paginationLabel
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
        
        let liClass: String
        let linkClass: String
        if useBootstrap4 {
            liClass = "page-item"
            linkClass = "page-link"
        }
        else {
            liClass = ""
            linkClass = ""
        }
        
        guard let url = url else {
            return "<li class=\"disabled \(liClass)\"><span class=\"\(linkClass)\" aria-label=\"Previous\" aria-hidden=\"true\">«</span><span class=\"sr-only\">Previous</span></li>\n".bytes
        }

        return "<li class=\"\(liClass)\"><a href=\"\(url)\" rel=\"prev\" aria-label=\"Previous\" class=\"\(linkClass)\"><span aria-hidden=\"true\">«</span><span class=\"sr-only\">Previous</span></a></li>\n".bytes
    }
    
    func buildForwardButton(url: String?) -> Bytes {

        let liClass: String
        let linkClass: String
        if useBootstrap4 {
            liClass = "page-item"
            linkClass = "page-link"
        }
        else {
            liClass = ""
            linkClass = ""
        }
        
        guard let url = url else {
            return "<li class=\"disabled \(liClass)\"><span aria-hidden=\"true\" class=\"\(linkClass)\">»</span></span><span class=\"sr-only\">Next</span></li>\n".bytes
        }
        
        return "<li class=\"\(liClass)\"><a href=\"\(url)\" rel=\"next\" class=\"\(linkClass)\" aria-label=\"Next\"><span class=\"sr-only\">Next</span><span aria-hidden=\"true\">»</span></a></li>\n".bytes
    }
    
    func buildLinks(currentPage: Int, count: Int) -> Bytes {
        var bytes: Bytes = []
        
        let linkClass: String
        let liClass: String
        let activeSpan = "<span class=\"sr-only\">(current)</span>"
        
        if useBootstrap4 {
            linkClass = "page-link"
            liClass = "page-item"
        }
        else {
            linkClass = ""
            liClass = ""
        }
        
        for i in 1...count {
            if i == currentPage {
                bytes += "<li class=\"active \(liClass)\"><span class=\"\(linkClass)\">\(i)</span>\(activeSpan)</li>\n".bytes
            } else {
                bytes += "<li><a href=\"?page=\(i)\" class=\"\(linkClass)\">\(i)</a></li>\n".bytes
            }
        }
        
        return bytes
    }
    
    func buildNavigation(currentPage: Int, totalPages: Int, links: [String : Polymorphic]) -> Node {
        var bytes: Bytes = []
        
        let navClass: String
        let ulClass: String
        if useBootstrap4 {
            navClass = "paginator"
            ulClass = "pagination justify-content-center"
        }
        else {
            navClass = "paginator text-center"
            ulClass = "pagination"
        }
        let header = "<nav class=\"\(navClass)\" aria-label=\"\(paginationLabel ?? "")\">\n<ul class=\"\(ulClass)\">\n".bytes
        let footer = "</ul>\n</nav>".bytes
        
        bytes += header
        
        bytes += buildBackButton(url: links["previous"]?.string)
        
        bytes += buildLinks(currentPage: currentPage, count: totalPages)
        
        bytes += buildForwardButton(url: links["next"]?.string)
        
        bytes += footer
        
        return .bytes(bytes)
    }
}

extension PaginatorTag.Error: Equatable {
    public static func ==(lhs: PaginatorTag.Error, rhs: PaginatorTag.Error) -> Bool {
        switch (lhs, rhs) {
        case (.expectedOneArgument(let a), .expectedOneArgument(let b)):
            return a == b
            
        case
            (.expectedVariable, .expectedVariable),
            (.expectedValidPaginator, .expectedValidPaginator):
                return true
            
        default:
            return false
        }
    }
}
