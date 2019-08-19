# NetAppKit

[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/) ![MIT License](https://img.shields.io/badge/license-MIT-blue.svg) ![language Swift 5.1](https://img.shields.io/badge/language-Swift%205.1-orange.svg) ![platform macOS](https://img.shields.io/badge/platform-macOS-lightgrey.svg)

Framework for making Express-like net apps using Swift NIO.

## License

NetAppKit is released under the MIT license. See `LICENSE` file for more detailed information.

## Example

```swift
import Foundation
import NetAppKit

let app = App()

app.handle(.GET, path: "/helloworld") { (request, response, _) in
    response.send("This is a test.")
}

app.handle(.GET, path: "/echo/:word") { (request, response, _) in
    response.send("Echoed word: \(request.parameter("word"))")
}

do {
    try app.listen(on: 4000)
} catch {
    dump(error)
}
```
