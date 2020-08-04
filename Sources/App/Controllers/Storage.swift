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
    
    init(node: Node) {
        
        self.node = node
        self.messages = [Message]()
        self.messagesIDs = [Int]()
        
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
                            
                //            log.storage.info('%s: ballot was added: %s', self.node.name, ballot)

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

//        log.storage.info('%s: message was added to pending: %s', self.node.name, message)
    }

    func isPending(message: Message) -> Bool {
    
        return self.pendingIDs.contains(message.messageID)
    }
}

