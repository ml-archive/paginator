import Core
import Leaf

public final class PaginatorTag: Tag {
    public enum Error: Swift.Error {
        case expectedOneArgument(got: Int)
        case expectedVariable
        case expectedValidPaginator(message: String)
    }
    
    fileprivate let useBootstrap4: Bool
    fileprivate let paginationLabel: String?
    fileprivate let visiblePages: Int?
    
    public init(useBootstrap4: Bool = false, paginationLabel: String? = nil, visiblePages: Int? = nil) {
        self.useBootstrap4 = useBootstrap4
        self.paginationLabel = paginationLabel
        self.visiblePages = visiblePages
    }
    
    public let name = "paginator"
    
    public func run(
        tagTemplate: TagTemplate,
        arguments: ArgumentList
    ) throws -> Node? {
        guard
            arguments.list.count == 1,
            let argument = arguments.list.first
        else {
                throw Error.expectedOneArgument(got: arguments.count)
        }
        
        guard case .variable(_, let value) = argument else {
            throw Error.expectedVariable
        }
        
        guard let paginator = value?["meta", "paginator"]?.object else {
            throw Error.expectedValidPaginator(message: "Couldn´t find meta: paginator object")
        }
        
        guard
            let currentPage = paginator[Keys.currentPage.key]?.int,
            let totalPages = paginator[Keys.totalPages.key]?.int,
            let links = paginator["links"]?.object
        else {
            let keys = paginator.map { $0.key }.joined(separator: ", ")
            throw Error.expectedValidPaginator(message: "Expected the keys \(Keys.currentPage.key), \(Keys.totalPages.key) and links, got: \(keys)")
        }
        
        let queries = paginator["queries"]

        return buildNavigation(
            currentPage: currentPage,
            totalPages: totalPages,
            links: links,
            queries: queries
        )
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
            return buildLink(title: "«", active: false, link: nil, disabled: true).bytes
        }

        return buildLink(title: "«", active: false, link: url, disabled: false).bytes
    }
    
    func buildForwardButton(url: String?) -> Bytes {
        guard let url = url else {
            return buildLink(title: "»", active: false, link: nil, disabled: true).bytes
        }
        
        return buildLink(title: "»", active: false, link: url, disabled: false).bytes
    }
    
    func buildLinks(
        currentPage: Int,
        count: Int,
        queries: Node?
    ) -> Bytes {
        var bytes: Bytes = []
        
        if count == 0 {
            return bytes
        }
        
        let visible = visiblePages ?? 8
        var pageOrder: [Int] = []
        
        pageOrder.append(currentPage)
        for i in 1...(visible/2) {
            
            if (currentPage + i) <= count {
                pageOrder.append(currentPage + i)
            }
            if (currentPage - i) > 0 {
                pageOrder.append(currentPage - i)
            }
            
        }
        pageOrder.sort()
        
        if pageOrder.count < visible {
            
            let missing = visible - pageOrder.count
            for _ in 1...missing {
                
                if pageOrder.first! == 1 {
                    // append element
                    pageOrder.append(pageOrder.last! + 1)
                } else {
                    // prepend element
                    pageOrder.insert(pageOrder.first! - 1, at: 0)
                }
            }
            
        } else if pageOrder.count > visible {
            if visible % 2 == 0 {
                pageOrder.removeFirst() 
            }   
        }

        
        for i in pageOrder {
            let path = PaginatorHelper.buildPath(page: i, count: count, uriQueries: queries)
            
            if i == currentPage {
                bytes += buildLink(title: "\(i)", active: true, link: nil, disabled: false).bytes
            } else {
                bytes += buildLink(title: "\(i)", active: false, link: path, disabled: false).bytes
            }
        }
        
        return bytes
    }
    
    func buildNavigation(
        currentPage: Int,
        totalPages: Int,
        links: [String : Node],
        queries: Node?
    ) -> Node {
        var bytes: Bytes = []
        
        let navClass: String
        let ulClass: String
        if useBootstrap4 {
            navClass = "paginator"
            ulClass = "pagination justify-content-center"
        } else {
            navClass = "paginator text-center"
            ulClass = "pagination"
        }
        var headerString = "<nav class=\"\(navClass)\""
        if let ariaLabel = paginationLabel {
            headerString += " aria-label=\"\(ariaLabel)\""
        }
        headerString += ">\n<ul class=\"\(ulClass)\">\n"
        let header = headerString.bytes
        let footer = "</ul>\n</nav>".bytes
        
        bytes += header
        
        bytes += buildBackButton(url: links["previous"]?.string)
        
        bytes += buildLinks(currentPage: currentPage, count: totalPages, queries: queries)
        
        bytes += buildForwardButton(url: links["next"]?.string)
        
        bytes += footer
        
        return .bytes(bytes)
    }
    
    func buildLink(title: String, active: Bool, link: String?, disabled: Bool) -> String {
        let linkClass: String?
        let liClass: String?
        let activeSpan = "<span class=\"sr-only\">(current)</span>"
        
        if useBootstrap4 {
            linkClass = "page-link"
            liClass = "page-item"
        } else {
            linkClass = nil
            liClass = nil
        }
        
        var linkString = "<li"
        
        if active || disabled || liClass != nil {
            linkString += " class=\""
            
            if active {
                linkString += "active"
            }
            if disabled {
                linkString += "disabled"
            }
            
            if let liClass = liClass {
                if active || disabled {
                    linkString += " "
                }
                linkString += "\(liClass)"
            }
            
            linkString += "\""
        }
        
        linkString += ">"
        
        if let link = link {
            linkString += "<a href=\"\(link)\""
            
            if let linkClass = linkClass {
                linkString += " class=\"\(linkClass)\""
            }
            
            if title == "«" {
                linkString += " rel=\"prev\" aria-label=\"Previous\"><span aria-hidden=\"true\">«</span><span class=\"sr-only\">Previous</span>"
            } else if title == "»" {
                linkString += " rel=\"next\" aria-label=\"Next\"><span aria-hidden=\"true\">»</span><span class=\"sr-only\">Next</span>"
            } else {
                linkString += ">\(title)"
            }
            
        } else {
            linkString += "<a><span"
            
            if let linkClass = linkClass {
                linkString += " class=\"\(linkClass)\""
            }
            
            if title == "«" {
                linkString += " aria-label=\"Previous\" aria-hidden=\"true\">«</span><span class=\"sr-only\">Previous</span>"
            } else if title == "»" {
                linkString += " aria-label=\"Next\" aria-hidden=\"true\">»</span><span class=\"sr-only\">Next</span>"
            } else {
                linkString += ">\(title)</span>"
                
                if active {
                    linkString += activeSpan
                }
            }
        }
        
        linkString += "</a></li>\n"
        
        return linkString
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
