//
//  TempMessage.swift
//  Stellar
//
//  Created by Sepand Yadollahifar on 7/27/20.
//  Copyright © 2020 Its3p. All rights reserved.
//

import Foundation
import CryptoKit

class Message: Codable {
    
    var messageID: Int
    var hashID: String
    var data: String
    var node: Node
    
    init?(messageID: Int, data: String, node: Node) {
        
        if let hid = Message.hash(data) {
            
            self.hashID = hid
            self.messageID = messageID
            self.data = data
            self.node = node
        } else {
            
            return nil
        }
    }
    
    static func hash(_ data: String) -> String? {
        
        // encode to utf8
        guard let data = data.data(using: .utf8) else { return nil }
        
        // hash to sha256
        let digest = SHA256.hash(data: data)
        
        // return hex string
        return digest.hexStr
    }
}


extension Message {
    
    static func ==(lhs: Message, rhs: Message) -> Bool {
        
        if lhs.messageID == rhs.messageID && lhs.data == rhs.data && lhs.node == rhs.node {
            
            return true
        }
        
        return false
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



final class BallotMessage: Message {
//    class InvalidBallotMessageError(Exception):
//        pass

    var state: State
    var result: BallotVoteResult

    init?( state: State, result: BallotVoteResult, messageID: Int, data: String, node: Node) {
        
        self.state = state
        self.result = result
        
        super.init(messageID: messageID, data: data, node: node)
        
    }
    
    enum CodingKeys: String, CodingKey {
        case state, result
    }


    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.result = try container.decode(BallotVoteResult.self, forKey: .result)
        self.state = try container.decode(State.self, forKey: .state)

        //pass my decoded values via a standard initializer
        try super.init(from: decoder)
    }
    
//    required init(from decoder: Decoder) throws {
//
//        try super.init(from: decoder)
//    }
}

extension BallotMessage {
    
    static func ==(lhs: BallotMessage, rhs: BallotMessage) -> Bool {
        
        if lhs.messageID == rhs.messageID && lhs.state == rhs.state && lhs.result == rhs.result && lhs.node == rhs.node && lhs.data == rhs.data {
             
            return true
        }
        
        return false
    }
}

