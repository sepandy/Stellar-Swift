//
//  Consensus.swift
//  Stellar
//
//  Created by Sepand Yadollahifar on 7/22/20.
//  Copyright © 2020 Its3p. All rights reserved.
//

import Vapor

class Consensus {
    
    // MARK: - Properties
    
    var name: String
    var quorum: Quorum
    var storage: Storage
    var ballot: Ballot
    var node: Node
    var Application: App
    
//    // MARK: - Init

    init(name: String, node: Node, quorum: Quorum, parent: App) {
        
        self.name = name
        self.node = node
        self.quorum = quorum
        self.storage = Storage(node: self.node, app: parent)
        
        self.ballot = Ballot(name: name, node: self.node, state: .none, nodeResult: nil, app: parent )
        self.ballot.change(state: .initialize)
        
        self.Application = parent
        
        self.Application.logger.debug("Consensus -- initially set state to \(self.node.name), \(self.ballot.state)")
    }
    
    func validate(message: Message) -> Bool {
        //
        //    # TODO implement
        //    is_validated = True
        //
        //    return is_validated
        return true
    }
    
    func receive(ballotMessage: BallotMessage) {
        
        self.Application.logger.debug("Consensus -- received ballot message \(self.node.name), \(ballotMessage)")

        if self.storage.doesHave(message: ballotMessage) {
                            
            self.Application.logger.debug("Consensus -- received ballot message is already stored")
            return
        }
                           
        self.handle(ballotMessage: ballotMessage)
    }
    
    func receive(message: Message) {
        
        self.Application.logger.debug("Consensus -- received message \(self.node.name), \(message)")
        
        if self.storage.doesHave(message: message) {
            
            self.Application.logger.debug("Consensus -- received message is already stored")
            return
        }
        
        self.handle(message: message)
    }
    
    func broadcast(ballotMessage: Data, skipNodes: [Node]? = nil){
        
        for node in self.quorum.validators {
            
            if let sn = skipNodes, sn.contains(where: { (nd) -> Bool in
                
                return nd == node
            }) {
                
                self.Application.logger.debug("Consensus -- broadcast is skipping node \(node)")
                continue
            }
            
            if let ws = node.socket {
                
                self.Application.send(data: ballotMessage, with: ws)
            }
        }
        
        self.ballot.isBroadcasted = true
    }


    func handle(message: Message) {

        if self.ballot.state != .initialize {
            
            self.Application.logger.debug("Consensus -- \(self.node.name): ballot state is not `init`, this message will be in stacked in pending storage, \(message)")
            
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
            do {
                
                self.Application.logger.debug("Consensus -- \(self.node.name): broadcast ballot_message initially, \(try? JSONDecoder().decode(BallotMessage.self, from: ballotMsg))")
            }
            
            
            self.broadcast(ballotMessage: ballotMsg, skipNodes: [message.node])
        }
    }
    func handle(ballotMessage: BallotMessage) {
    
//         if ballot_message is from unknown node, just ignore it
        
        if ballotMessage.node.quorum != self.quorum {
            
            self.Application.logger.debug("Consensus -- \(self.node.name): message from outside quorum, \(ballotMessage)")

            return
        }
//         if ballot_message.state is older than state of node, just ignore it
        if ballotMessage.state < self.ballot.state {
            
            return
        }
        
        let isBallotEmpty = self.ballot.isEmpty()
        
        self.Application.logger.debug("Consensus -- \(self.node.name): ballot is empty? \(isBallotEmpty)")

        if isBallotEmpty { //  ballot is empty, just embrace ballot
            
            self.ballot.set(message: ballotMessage)
        }
        
        let isBallotMessageValid = self.ballot.isValid(ballotMessage: ballotMessage)

        self.Application.logger.debug("Consensus -- \(self.node.name): ballot_message is valid? \(isBallotMessageValid)")

        if !isBallotMessageValid {
            self.Application.logger.debug("Consensus -- \(self.node.name): unexpected ballot_message was received: expected != given\n\(self.ballot.dict)\n\(ballotMessage.dict)")

            return
        }
    
        self.ballot.vote(for: ballotMessage.node, with: ballotMessage.result, and: ballotMessage.state)

        let (state, hasPassedThershhold) = self.ballot.checkThreshold()
  
    
//        # if new state was already agreed from other validators, the new ballot
//        # will be accepted
        if hasPassedThershhold && state != self.ballot.state {
            
            self.ballot.change(state: state)
        }
        
        self.Application.logger.debug("Consensus -- \(self.node.name): is passed threshold? \(hasPassedThershhold), \(ballotMessage)")
    
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

        self.Application.logger.debug("Consensus -- \(self.node.name): new ballot broadcasted \(self.ballot)")
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
                        
                        self.Application.logger.debug("Consensus -- \(self.node.name): new ballot broadcasted \(self.ballot)")
                        // log
                    }
                }
            
                return hasPassedThreshhold
            case .sign, .accept:
            
                return hasPassedThreshhold
            
            case .allConfirm:
            
                self.Application.logger.debug("Consensus -- \(self.node.name), \(self.ballot.state), \(ballotMessage)")
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




