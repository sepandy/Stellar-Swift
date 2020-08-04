//
//  Consensus.swift
//  Stellar
//
//  Created by Sepand Yadollahifar on 7/22/20.
//  Copyright © 2020 Its3p. All rights reserved.
//

import Foundation

class Consensus {
    
    // MARK: - Properties
    
    var name: String
    var quorum: Quorum
    var storage: Storage
    var ballot: Ballot
    var node: Node
//    
//    // MARK: - Init
//    
    init(name: String, node: Node, quorum: Quorum) {
        
        self.name = name
        self.node = node
        self.quorum = quorum
//        self.transport = transport
        self.storage = Storage(node: self.node)
        
        self.ballot = Ballot(name: name, node: self.node, state: .none, nodeResult: nil)
        self.ballot.change(state: .initialize)
        
        //    log.consensus.debug(
        //        '%s: initially set state to %s',
        //        self.node.name, self.ballot.state,
        //    )
    }
    
    func validate(message: Message) -> Bool {
        //
        //    # TODO implement
        //    is_validated = True
        //
        //    return is_validated
        return true
    }
    
    func receive(data: Data) {
        
        //        log.consensus.debug('%s: received data: %s', self.node.name, data)
        
        do {
            
            if let blmsg = try? JSONDecoder().decode(BallotMessage.self, from: data) {
                
//                log.consensus.debug('%s: received data is %s', self.node.name, loaded)
                
                if self.storage.doesHave(message: blmsg) {
                    
//                    log.consensus.debug('%s: already stored: %s', self.node.name, loaded)
                    return
                }
                   
                    self.handle(ballotMessage: blmsg)
                
            } else if let msg = try? JSONDecoder().decode(Message.self, from: data) {
                
                // log
                
                if self.storage.doesHave(message: msg) {
                    
                    //log
                    return
                }
                
                self.handle(message: msg)
            }

        }


    }
    
    func broadcast(ballotMessage: Data, skipNodes: [Node]? = nil){
        
        for node in self.quorum.validators {
            
            if let sn = skipNodes, sn.contains(where: { (nd) -> Bool in
                
                return nd == node
            }) {
                
                continue
            }
            
//            self.transport.send(
//                node.endpoint,
//                ballot_message,
//            )
        }
        
        self.ballot.isBroadcasted = true
    }


    func handle(message: Message) {

        //log.consensus.debug('%s: received message: %s', self.node.name, message)
    
        if self.ballot.state != .initialize {
//            log.consensus.debug(
//                '%s: ballot state is not `init`, this message will be in stacked in pending storage',
//                self.node.name,
//                message,
//            )
            self.storage.addPending(message: message)
    
            return
        }
        
        if self.ballot.state == .initialize {
            
            if self.ballot.isEmpty() {
                
                self.ballot.set(message: message)
            } else {
                
                self.storage.addPending(message: message)
                return
            }
        }

        self.ballot.nodeResult = self.validate(message: message) ? .agree : .disagree
        self.ballot.vote(for: self.node, with: self.ballot.nodeResult ?? .disagree, and: .initialize)
  
        if let ballotMsg = self.ballot.serializedBallotMessage() {
            //        log.consensus.debug('%s: broadcast ballot_message initially: %s', self.node.name, ballot_message.strip())
    
            self.broadcast(ballotMessage: ballotMsg, skipNodes: [message.node])
        }
    }
    func handle(ballotMessage: BallotMessage) {
//        log.consensus.debug(
//            '%s: %s: received ballot_message: %s',
//            self.node.name,
//            self.ballot.state,
//            ballot_message,
//        )
    
//        # if ballot_message is from unknown node, just ignore it
        
        if ballotMessage.node.quorum != self.quorum {
            //            log.consensus.debug(
            //                '%s: message from outside quorum: %s',
            //                self.node.name,
            //                ballot_message,
            //            )
            return
        }
//        # if ballot_message.state is older than state of node, just ignore it
        if ballotMessage.state < self.ballot.state {
            
            return
        }
        

//        log.consensus.debug('%s: ballot is empty?: %s', self.node.name, self.ballot.isEmpty())
        if self.ballot.isEmpty() { // # ballot is empty, just embrace ballot
            
            self.ballot.set(message: ballotMessage)
        }

//        log.consensus.debug('%s: ballot_message is valid?: %s', self.node.name, is_valid_ballot_message)
        if !self.ballot.isValid(ballotMessage: ballotMessage) {
//            log.consensus.error(
//                '%s: unexpected ballot_message was received: expected != given\n%s\n%s',
//                self.node.name,
//                self.ballot.__dict__,
//                ballot_message.__dict__,
//            )
            return
        }
    
        self.ballot.vote(for: ballotMessage.node, with: ballotMessage.result, and: ballotMessage.state)

        let (state, hasPassedThershhold) = self.ballot.checkThreshold()
  
    
//        # if new state was already agreed from other validators, the new ballot
//        # will be accepted
        if hasPassedThershhold && state != self.ballot.state {
            
            self.ballot.change(state: state)
        }
    
//        log.consensus.debug(
//            '%s: is passed threshold?: %s: %s',
//            self.node.name,
//            is_passed_threshold,
//            ballot_message,
//        )
//
        

        if self.handle(state: self.ballot.state, of: ballotMessage, when: hasPassedThershhold) {

            return
        }
            
    
        if let nextState = self.ballot.state.getNext() {
            
            self.ballot.change(state: nextState)
            
            if nextState == .allConfirm {
                
                self.handle(state: .allConfirm, of: ballotMessage, when: hasPassedThershhold)
                return
            }
        } else {
            
            return
        }

        self.ballot.nodeResult = self.validate(message: ballotMessage) ? .agree : .disagree
        self.ballot.vote(for: self.node, with: self.ballot.nodeResult!, and: self.ballot.state)
        
        if let data = self.ballot.serializedBallotMessage() {
            
            self.broadcast(ballotMessage: data)
        }

    
//        log.consensus.debug('%s: new ballot broadcasted: %s', self.node.name, self.ballot)
 
    }
    
    @discardableResult func handle(state: State, of ballotMessage: BallotMessage, when hasPassedThreshhold: Bool) -> Bool {
        
        switch state {
            case .initialize:
            
                if self.ballot.nodeResult == nil {
                    
                    self.ballot.nodeResult = self.validate(message: ballotMessage) ? .agree : .disagree
                    self.ballot.vote(for: self.node, with: self.ballot.nodeResult!, and: self.ballot.state)
                }
            
                if !self.ballot.isBroadcasted {
                    
                    if let data = self.ballot.serializedBallotMessage() {
                        
                        self.broadcast(ballotMessage: data)
                        
                        // log
                    }
                }
            
                return hasPassedThreshhold
            case .sign, .accept:
            
                return hasPassedThreshhold
            
            case .allConfirm:
            
                //    log.consensus.info('%s: %s: %s', self.node.name, self.ballot.state, ballot_message)
                let result = self.storage.add(ballot: self.ballot)
            
                if result {
                    
                    self.ballot.initializeState()
                }
                
            
                //# FIXME this is for simulation purpose
                //self.reached_all_confirm(ballot_message)
            
                return result
            default:
            
                return false
        }
    }

}




