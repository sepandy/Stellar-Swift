import Vapor

func routes(_ app: Application) throws {
//    app.get { req in
//        return "It works!"
//    }
//
//    app.get("hello") { req -> String in
//        return "Hello, world!"
//    }
    
    app.webSocket("echo") { req, ws in
        // Connected WebSocket.
        print(ws)
    }
    
//    WebSocket.connect(to: "ws://echo.websocket.org", on: eventLoop) { ws in
//        // Connected WebSocket.
//        print(ws)
//    }
//    
//    WebSocket.send("Hello, world")
}
