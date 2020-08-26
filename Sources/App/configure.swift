import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    let application = App(eventLoop: app.eventLoopGroup.next())
    // register routes
    
    app.webSocket("connect") { req, ws in
        application.connect(ws)
    }
//
//    app.webSocket(<#T##path: PathComponent...##PathComponent#>, onUpgrade: <#T##(Request, WebSocket) -> ()#>)
//
//    try routes(app)
}
