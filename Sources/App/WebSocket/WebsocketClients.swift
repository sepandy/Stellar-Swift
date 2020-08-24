//
//  WebsocketClients.swift
//  
//
//  Created by Sepand Yadollahifar on 8/4/20.
//

import Vapor

open class WebsocketClients {
    var eventLoop: EventLoop
    var storage: [UUID: WebSocketClient]
    
    var active: [WebSocketClient] {
        self.storage.values.filter { !($0.socket?.isClosed ?? false) }
    }

    init(eventLoop: EventLoop, clients: [UUID: WebSocketClient] = [:]) {
        self.eventLoop = eventLoop
        self.storage = clients
    }
    
    func add(_ client: WebSocketClient) {
        self.storage[client.id] = client
    }

    func remove(_ client: WebSocketClient) {
        self.storage[client.id] = nil
    }
    
    func find(_ uuid: UUID) -> WebSocketClient? {
        self.storage[uuid]
    }

    deinit {
        let futures = self.storage.values.map { $0.socket?.close() }
        var fs = [EventLoopFuture<Void>]()
        
        for f in futures {
            
            if let future = f {
                
                fs.append(future)
            }
        }
        
        try! self.eventLoop.flatten(fs).wait()
    }
}
