//
//  WebSocketClient.swift
//  
//
//  Created by Sepand Yadollahifar on 8/4/20.
//

import Vapor

open class WebSocketClient {
    open var id: UUID
    open var socket: WebSocket?

    public init(id: UUID, socket: WebSocket?) {
        self.id = id
        self.socket = socket
    }
}
