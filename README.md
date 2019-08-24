# NetAppKit

[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/) ![MIT License](https://img.shields.io/badge/license-MIT-blue.svg) ![language Swift 5.1](https://img.shields.io/badge/language-Swift%205.1-orange.svg) ![platform macOS](https://img.shields.io/badge/platform-macOS-lightgrey.svg) ![platform Linux](https://img.shields.io/badge/platform-Linux-lightgrey.svg)

Framework for making Express-like net apps using Swift NIO.

## License

NetAppKit is released under the MIT license. See `LICENSE` file for more detailed information.

# Table of Contents

- [Getting Started](#getting-started)
- [Reference Documentation](#reference-documentation)
- [Example](#example)

# Getting Started

Add NetAppKit to your Swift package by adding the following to your `Package.swift` file in
the dependencies array:

```swift
.package(url: "https://github.com/apparata/NetAppKit.git", from: "<version>")
```
If you are using Xcode 11 or newer, you can add NetAppKit by entering the URL to the
repository via the `File` menu:

```
File > Swift Packages > Add Package Dependency...
```

**Note:** NetAppKit requires **Swift 5.1** or later.

## Reference Documentation

There is generated [reference documentation](https://apparata.github.io/NetAppKit/NetAppKit/)
available.

## Example

```swift
import Foundation
import NetAppKit

let app = App()

app.handle(.GET, path: "/helloworld") { (request, response) in
    response.send("This is a test.")
    return .handled
}

app.handle(.GET, path: "/echo/:word") { (request, response) in
    response.send("Echoed word: \(request.parameter("word"))")
    return .handled
}

// Subapp that is installed on /date, so /today endpoint will be /date/today
let subapp = App()

subapp.handle(.GET, path: "/today") { (request, response) in
    response.send("Today's date is \(Date())")
    return .handled
}

app.installSubapp(subapp, path: "/date")

do {
    let server = AppServer(app: app)
    try server.listen(on: 4000)
} catch {
    dump(error)
}
```
