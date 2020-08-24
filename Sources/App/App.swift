//
//  File.swift
//  
//
//  Created by Sepand Yadollahifar on 8/4/20.
//

import Vapor

class App {
    
    var clients: WebsocketClients
    var consensus: Consensus
    var logger: Logger

    init(eventLoop: EventLoop) {
        
        self.logger = Logger(label: "Application Log")
        self.clients = WebsocketClients(eventLoop: eventLoop)
        
        let q = Quorum(threshold: 80, validators: [])
        
        
        // for now every time that app runs builds resets
        // in new version have to implement loading from backup/storgae feature
        self.consensus = Consensus(name: "Test-1", node: Node(name: "Node-1", endpoint: URL(string: "sock://node-1")!, quorum: q, id: UUID(String("1")) ?? UUID(), socket: nil), quorum: q, parent: self)
    
    }
    
    func connect(_ ws: WebSocket) {
        
        ws.onBinary { [unowned self] ws, buffer in
            
            if let msg = buffer.decodeWebsocketMessage(Node.self) {
                
                self.logger.info("Connected to a node with info:\n Name: \(msg.data.name)\n ID:\(msg.client)\n Endpoint:\(msg.data.endpoint)")
                
                let node = Node(name: msg.data.name, endpoint: msg.data.endpoint, quorum: msg.data.quorum, id: msg.client, socket: ws)

                self.clients.add(node)
            } else {
                
                self.logger.warning("Failed to decode websocket connect message \(buffer)")
            }
        }
    }
    
    func receive(_ ws: WebSocket) {
        
        ws.onBinary { ws, buffer in
            
            if let msg = buffer.decodeWebsocketMessage(Message.self) {
                
                
                
            } else if let blmsg = buffer.decodeWebsocketMessage(BallotMessage.self) {
                
                
            } else {
                
                
            }
        }
    }
    
    
    func send(data: Data, with ws: WebSocket) {
        
        let arr = data.bytes
        
        let promise = eventLoop.makePromise(of: Void.self)
        ws.send(arr, promise: promise)
        promise.futureResult.whenComplete { result in
            // Succeeded or failed to send.
            
        }
    }
}
