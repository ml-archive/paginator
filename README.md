# Paginator
[![Language](https://img.shields.io/badge/Swift-3-brightgreen.svg)](http://swift.org)
[![Build Status](https://travis-ci.org/nodes-vapor/paginator.svg?branch=master)](https://travis-ci.org/nodes-vapor/paginator)
[![codecov](https://codecov.io/gh/nodes-vapor/paginator/branch/master/graph/badge.svg)](https://codecov.io/gh/nodes-vapor/paginator)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/nodes-vapor/paginator/master/LICENSE)

Query pagination for Vapor and Fluent.

## Integration
Update your `Package.swift` file.
```swift
.Package(url: "https://github.com/nodes-vapor/paginator", majorVersion: 0)
```

## Getting started 🚀
Paginator does most of the hard work for you. Create and return a  paginated [Model](https://vapor.github.io/documentation/fluent/model.html) like so:
```swift
import Vapor
import Paginator

drop.get("models") { req in
    // returns a pagination of 10 `MyModel`s.
    return try MyModel.paginator(10, request: req)
}
```

## Rendering views with 🍃
What would pagination be without handy-dandy view rendering? Nothing. Before you can begin rendering paginators, you need to registor the custom tag with your droplet.

### main.swift
```swift
import Vapor
import Paginator

let drop = Droplet()
// ... provider setup

if let view = drop.view as? LeafRenderer {
    view.stem.register(PaginatorTag())
}
```

Good! Now, pass a `Paginator` to your 🍃 templates like so:

### main.swift
```swift
drop.get("/") { req in
    let posts = try Post.paginator(10, request: req)
    
    return try drop.view.make("index", [
        "posts": try posts.makeNode()
    ])
}
```

Inside of your 🍃 template you can iterate over your paginator's entities by accessing the paginator's `data` field.

### index.leaf
```html
#loop(posts.data, "post") {
<div class="post">
  <span class="date">#(post.date)</span>
  <span class="text">#(post.content)</span>
</div>
}
```

Finally, the pièce de résistance: navigation controllers using paginators and 🍃.

### index.leaf
```html
#paginator(posts)
```

## Overriding the `page` query key
If you don't like the query key `page`, you can override it at the paginator callsite.
```swift
//...
return try MyModel.paginator(10, pageName: "slide", request: req)
```

The query string will now have the value `?slide=1&count=10`

## Overriding the `data` JSON key
If you wish to be more explicit with the name of your data, you can override the default JSON key.
```swift
return try MyModel.paginator(10, dataKey: "my_models")
```

The JSON response will now look like:
```
{
    "my_models": [
        // models here
    ],

    "meta": {
        "paginator": {
            //...
        }
    }
}
```

## 🏆 Credits
This package is developed and maintained by the Vapor team at [Nodes](https://www.nodes.dk).

## 📄 License
This package is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT)