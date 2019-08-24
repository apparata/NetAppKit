//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation
import NetAppKit

let app = App()

app.handle(.GET, path: "/helloworld") { request, response in
    response.send("This is a test.")
    return .handled
}

app.handle(.GET, path: "/echo/:word") { request, response in
    response.send("Echoed word: \(request.parameter("word"))")
    return .handled
}

app.handle(.GET, path: "/json/please") { request, response in
    struct Stuff: Codable {
        let someStuff: String
        let aNumber: Int
    }
    response.sendJSON(Stuff(someStuff: "stuff", aNumber: 5))
    return .handled
}

// Subapp that is installed on /date, so /today endpoint will be /date/today
let subapp = App()

subapp.handle(.GET, path: "/today") { request, response in
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
