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