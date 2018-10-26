# Paginator 📄
[![Swift Version](https://img.shields.io/badge/Swift-4.2-brightgreen.svg)](http://swift.org)
[![Vapor Version](https://img.shields.io/badge/Vapor-3-30B6FC.svg)](http://vapor.codes)
[![Circle CI](https://circleci.com/gh/nodes-vapor/paginator/tree/master.svg?style=shield)](https://circleci.com/gh/nodes-vapor/paginator)
[![codebeat badge](https://codebeat.co/badges/292edd79-f237-4df5-8d6b-9ef748148d80)](https://codebeat.co/projects/github-com-nodes-vapor-paginator-master)
[![codecov](https://codecov.io/gh/nodes-vapor/paginator/branch/master/graph/badge.svg)](https://codecov.io/gh/nodes-vapor/paginator)
[![Readme Score](http://readme-score-api.herokuapp.com/score.svg?url=https://github.com/nodes-vapor/paginator)](http://clayallsopp.github.io/readme-score?url=https://github.com/nodes-vapor/paginator)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/nodes-vapor/paginator/master/LICENSE)

![GIF of paginator](https://raw.githubusercontent.com/nodes-vapor/paginator/master/assets/demo.gif)

This package currently offers support for offset pagination on `Array` and `QueryBuilder`.

## 📦 Installation

Add `Paginator` to the package dependencies (in your `Package.swift` file):
```swift
dependencies: [
    ...,
    .package(url: "https://github.com/nodes-vapor/paginator.git", from: "3.0.0-beta")
]
```

as well as to your target (e.g. "App"):

```swift
targets: [
    ...
    .target(
        name: "App",
        dependencies: [... "Paginator" ...]
    ),
    ...
]
```

Next, copy/paste the `Resources/Views/Paginator` folder into your project in order to be able to use the provided Leaf tags. These files can be changed as explained in the [Leaf Tags](#leaf-tags) section, however it's recommended to copy this folder to your project anyway. This makes it easier for you to keep track of updates and your project will work if you decide later on to not use your own customized leaf files.

## Getting started 🚀

First make sure that you've imported Submissions everywhere it's needed:

```swift
import Sugar
```

### Adding the Leaf tag

In order to do pagination in Leaf, please make sure to add the Leaf tag:

```swift
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    services.register { _ -> LeafTagConfig in
        var tags = LeafTagConfig.default()
        tags.use([
            "offsetPaginator": OffsetPaginatorTag(templatePath: "Paginator/offsetpaginator")
        ])

        return tags
    }
}
```

If you want to fully customize the way the pagination control are being generated, you are free to override the template path.

### `QueryBuilder`

To return a paginated result from `QueryBuilder`, you can do the following:

```swift
router.get("galaxies") { (req: Request) -> Future<OffsetPaginator<Galaxy>> in
    return Galaxy.query(on: req).paginate(on: req)
}
```

### `Array`

For convenience, Paginator also comes with support for paginating `Array`:

```swift
router.get("galaxies") { (req: Request) -> Future<OffsetPaginator<Galaxy>> in
    let galaxies = [Galaxy(), Galaxy(), Galaxy()]
    return galaxies.paginate(on: req)
}
```

## Leaf tags

To use Paginator together with Leaf, you can do the following:

```swift
router.get("galaxies") { (req: Request) -> Response in
    let paginator: Future<OffsetPaginator<Galaxy>> = Galaxy.query(on: req).paginate(on: req)
    return paginator.flatMap(to: Response.self) { paginator in
        return try req.view().render(
            "MyLeafFile", 
            GalaxyList(galaxies: paginator.data ?? []), 
            userInfo: try paginator.userInfo()
        )
        .encode(for: req)
    }
}
```

> Please note how the Paginator data is being passed in using `userInfo` on the `render` call. Forgetting to pass this in will result in an error being thrown.

Then in your `MyLeafFile.leaf` you could do something like:

```html
<ul>
    #for(galaxy in galaxies) {
        <li>#(galaxy.name)</li>
    }
</ul>

#offsetPaginator()
```

Calling the leaf tag for `OffsetPaginator` will automaticaly generate the Bootstrap 4 HTML for showing the pagination controls:

```html
<nav class="paginator">
    <ul class="pagination justify-content-center table-responsive">
        <li class="page-item">
            <a href="/admin/users?page=16" class="page-link" rel="prev" aria-label="Previous">
                <span aria-hidden="true">«</span>
                <span class="sr-only">Previous</span>
            </a>
        </li>
        <li class="page-item "><a href="/admin/users?page=1" class="page-link">1</a></li>
        <li class="disabled page-item"><a href="#" class="page-link">...</a></li>
        <li class="page-item "><a href="" class="page-link">12</a></li>
        <li class="page-item "><a href="" class="page-link">13</a></li>
        <li class="page-item "><a href="" class="page-link">14</a></li>
        <li class="page-item "><a href="" class="page-link">15</a></li>
        <li class="page-item "><a href="" class="page-link">16</a></li>
        <li class="page-item  active "><a href="" class="page-link">17</a></li>
        <li class="page-item "><a href="/admin/users?page=18" class="page-link">18</a></li>
        <li class="page-item">
            <a href="/admin/users?page=18" class="page-link" rel="next" aria-label="Next">
                <span aria-hidden="true">»</span>
                <span class="sr-only">Next</span>
            </a>
        </li>
    </ul>
</nav>
```


## Configuration

The `OffsetPaginator` has a configuration file (`OffsetPaginatorConfig`) that can be overwritten if needed. This can be done in `configure.swift`:

```swift
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // ..
    services.register(OffsetPaginatorConfig(
        perPage: 1,
        defaultPage: 1
    ))
}
```


## 🏆 Credits

This package is developed and maintained by the Vapor team at [Nodes](https://www.nodesagency.com).
The package owner for this project is [Siemen](https://github.com/siemensikkema/).


## 📄 License

This package is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT)
