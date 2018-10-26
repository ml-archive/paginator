# Paginator 📄
[![Swift Version](https://img.shields.io/badge/Swift-4.2-brightgreen.svg)](http://swift.org)
[![Vapor Version](https://img.shields.io/badge/Vapor-3-30B6FC.svg)](http://vapor.codes)
[![Circle CI](https://circleci.com/gh/nodes-vapor/paginator/tree/master.svg?style=shield)](https://circleci.com/gh/nodes-vapor/paginator)
[![codebeat badge](https://codebeat.co/badges/292edd79-f237-4df5-8d6b-9ef748148d80)](https://codebeat.co/projects/github-com-nodes-vapor-paginator-master)
[![codecov](https://codecov.io/gh/nodes-vapor/paginator/branch/master/graph/badge.svg)](https://codecov.io/gh/nodes-vapor/paginator)
[![Readme Score](http://readme-score-api.herokuapp.com/score.svg?url=https://github.com/nodes-vapor/paginator)](http://clayallsopp.github.io/readme-score?url=https://github.com/nodes-vapor/paginator)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/nodes-vapor/paginator/master/LICENSE)

Query pagination for Vapor and Fluent.

![GIF of paginator](https://cloud.githubusercontent.com/assets/1977704/21704234/c4f7a9a8-d36c-11e6-8522-7043d51b21b2.gif)


## 📦 Installation

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

What would pagination be without handy-dandy view rendering? Nothing. Before you can begin rendering paginators, you need to register the custom tag with your droplet. We have a [Provider](https://vapor.github.io/documentation/guide/provider.html) that will register the tag for you.

### main.swift
```swift
import Vapor
import Paginator

let drop = Droplet()
try drop.addProvider(PaginatorProvider.self)
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
```json
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


## Overriding the deafult response formatter

In case you've defined specific formatters for your data, you can override the default formatter

```swift
let signups: Paginator<SignUp> = try query.paginator(25, request: request) { signups in
            return try signups.map { signup in
                return try signup.makeNode()
            }.makeNode()
        }
```


## Using Bootstrap 4

By default, Paginator prints Bootstrap 3-compatible HTML in Leaf, however it is possible to configure it to use Bootstrap 4. You can add a `paginator.json` file to your Config directory with the values:

```json
{
    "useBootstrap4": true
}
```

You can alternatively manually build the Paginator Provider and add it to your `Droplet`:

```swift
let paginator = PaginatorProvider(useBootstrap4: true)
drop.addProvider(paginator)
```


## Specifying an Aria Label 

The Paginator HTML adds in Aria labels for accessibility options, such as screen readers. It is recommended that you add a label to your paginator to assist this. This can be done in the same way as the Bootstrap 4 options. Either in `paginator.json`:

```json
{
    "paginatorLabel": "Blog Post Pages"
}
```

Or manually:

```swift
let paginator = PaginatorProvider(paginationLabel: "Blog Post Pages")
drop.addProvider(paginator)
```

The two configurable options (label and Bootstrap 4) can obviously be combined.


## 🏆 Credits

This package is developed and maintained by the Vapor team at [Nodes](https://www.nodesagency.com).
The package owner for this project is [Siemen](https://github.com/siemensikkema/).


## 📄 License

This package is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT)
