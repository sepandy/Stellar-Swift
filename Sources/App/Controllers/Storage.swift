//
//  Storage.swift
//  Stellar
//
//  Created by Sepand Yadollahifar on 7/27/20.
//  Copyright © 2020 Its3p. All rights reserved.
//

import Foundation


class Storage {
    
    // MARK: - Properties
    
    var node: Node
    var messages: [Message]
    var messagesIDs: [Int]
    var ballotHistory: [Int: [String: Any]]
    var pending: [Message]
    var pendingIDs: [Int]
    var application: App
    
    init(node: Node, app: App) {
        
        self.node = node
        self.messages = [Message]()
        self.messagesIDs = [Int]()
        
        self.application = app
        self.ballotHistory = [Int: [String: Any]]()
        
        self.pending = [Message]()
        self.pendingIDs = [Int]()
    }
    
    func add(ballot: Ballot) -> Bool {
        
        if ballot.state == .allConfirm {
            
            if let blmsg = ballot.message {
                
                self.messages.append(blmsg)
                self.messagesIDs.append(blmsg.messageID)
                
                if let dict = ballot.dict {
                    
                    self.ballotHistory[blmsg.messageID] = dict
                }
                            
                self.application.logger.info("Storage -- \(self.node.name): \(node ) ballot was added \(ballot)")
                return true
            }
        }
        
        return false
    }
    
    func doesHave(message: Message) -> Bool {
        
        return self.messagesIDs.contains(message.messageID)
    }
    
    func addPending(message: Message) {

        self.pending.append(message)
        self.pendingIDs.append(message.messageID)

        self.application.logger.info("Storage -- \(self.node.name): message was added to pending: \(message)")
    }

    func isPending(message: Message) -> Bool {
    
        return self.pendingIDs.contains(message.messageID)
    }
}

