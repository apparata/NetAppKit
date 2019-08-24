//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

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
