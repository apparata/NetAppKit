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
    response.send("Echoed word: \(request.parameter("word") ?? "N/A")")
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

app.handle(.GET, path: "/parameters/:arg0?arg1=banana") { request, response in
    struct Stuff: Codable {
        let arg0: String
        let arg1: String
    }
    response.sendJSON(Stuff(arg0: request.parameter("arg0") ?? "N/A", arg1: request.parameter("arg1") ?? "N/A"))
    return .handled
}

// Subapp that is installed on /date, so /today endpoint will be /date/today
let subapp = App()

subapp.validateAPIKey = { apiKey in
    apiKey == "1234"
}

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
