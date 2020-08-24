//
//  Node.swift
//  Stellar
//
//  Created by Sepand Yadollahifar on 7/22/20.
//  Copyright © 2020 Its3p. All rights reserved.
//

import Vapor

class Node: WebSocketClient, Codable {
    
    var name: String
    var endpoint: URL
    var quorum: Quorum
    
    init(name: String, endpoint: URL, quorum: Quorum, id: UUID, socket: WebSocket?) {
        
        self.name = name
        self.endpoint = endpoint
        self.quorum = quorum
        super.init(id: id, socket: socket)
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case endpoint
        case quorum
        case id
    }
    
    required init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try values.decode(String.self, forKey: .name)
        self.endpoint = try values.decode(URL.self, forKey: .endpoint)
        self.quorum = try values.decode(Quorum.self, forKey: .quorum)
        
        let id = try values.decode(UUID.self, forKey: .id)
        let socket = decoder.userInfo[CodingUserInfoKey(rawValue: "websocket")!] as? WebSocket
        super.init(id: id, socket: socket)

    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(name)
        try container.encode(id)
        try container.encode(endpoint)
        try container.encode(quorum)
    }
}

extension Node: Equatable {
    
    static func ==(lhs: Node, rhs: Node) -> Bool {
        
        if lhs.name == rhs.name && lhs.endpoint == rhs.endpoint {
            
            return true
        }
        
        return false
    }
}

