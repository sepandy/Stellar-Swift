//
//  Node.swift
//  Stellar
//
//  Created by Sepand Yadollahifar on 7/22/20.
//  Copyright © 2020 Its3p. All rights reserved.
//

import Foundation

class Node: WebSocketClient {
    
    var name: String
    var endpoint: URL?
    var quorum: Quorum
    
    init(name: String, endpoint: URL?, quorum: Quorum) {
        
        self.name = name
        self.endpoint = endpoint
        self.quorum = quorum
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

