//
//  Ballot.swift
//  Stellar
//
//  Created by Sepand Yadollahifar on 7/24/20.
//  Copyright © 2020 Its3p. All rights reserved.
//

import Foundation

class Ballot {
    
    // MARK: - Properties
    
    var state: State
    var stateHistory: [State]
    var name: String
    var message: Message?
    var voted: [Int: [String: BallotVoteResult]]
    var isBroadcasted: Bool
    var nodeResult: BallotVoteResult?
    var node: Node
    
//    self.vote_history = dict()
//    self.node_result = node_result
    
    init(name: String, node: Node, state: State, nodeResult: BallotVoteResult?) {
        
        self.node = node
        self.isBroadcasted = false
        self.message = nil
        self.state = state
        self.nodeResult = nodeResult
        self.stateHistory = []
        self.name = name
        self.voted = [:]
    }
    
    func isValid(ballotMessage: BallotMessage) -> Bool {
        
//        if self.state != ballotMessage.state {
//
//            return false
//        }
        
        if let smsg = self.message {
            
            return smsg == ballotMessage
        }
        
        return false
    }

    func initializeState() {
        
        self.state = .none
        self.message = nil
//        self.voted = dict()
        self.isBroadcasted = false
//        self.node_result = None
    }


    func change(state: State) {
        
        self.stateHistory.append(state)
//        if self.state.value in self.voted:
//            self.vote_history[self.state.name] = self.voted[self.state.value]

        self.state = state
//        self.voted = dict()
        self.isBroadcasted = false
    }

    func set(message: Message) {
    
        self.message = message
//        self.voted = dict()
    }

    

    func isEmpty() -> Bool {
        
        return self.message == nil
    }

    func isVoted(node: Node) -> Bool {
        
        return self.voted.contains { (_, val) -> Bool in
            
            return val.contains { (key, _) -> Bool in
                
                return key == node.name
            }
        }
    }
        
    func vote(for node: Node, with result: BallotVoteResult, and state: State) {
        
        if self.state > state {
            
//            log.ballot.debug(
//                           '%s: same message and previous state: %s: %s',
//                           self.node.name,
//                           state,
//                       )
            return
        }
        
        if !self.voted.contains(where: { (key, _) -> Bool in
            
            return key == state.rawValue
        }) {
            
            self.voted[state.rawValue] = [String: BallotVoteResult]()
        }
        
        if self.voted[state.rawValue]!.contains(where: { (key, _) -> Bool in
            
            return key == node.name
        }) {
            
            //# existing vote will be overrided
            //log.ballot.debug('%s: already voted?: %s', self.node.name)

        }

//         if node.name in self.voted:
//             raise Ballot.AlreadyVotedError('node, %s already voted' % node_name)
//             return

        self.voted[state.rawValue]![node.name] = result
//        log.ballot.info('%s: %s voted for %s', self.node.name, node, self.message)

        return

    }

    func checkThreshold() -> (State, Bool) {
    
        var votedCopy = self.voted
        let states = self.voted.keys.sorted()
        
        if states.count < 1 {
            
            return (self.state, false)
        }
        

        for stateVal in states {
                
            if stateVal < self.state.rawValue {
                    
                votedCopy.removeValue(forKey: stateVal)
                continue
            }
                
            if let target = votedCopy[stateVal] {
                    
                let agreedVotesCount = target.filter({ (bvr) -> Bool in
                        
                    return bvr.value == .agree
                    }).count
                    
                let isPassed = agreedVotesCount >= self.node.quorum.minimumQuorum()
                    
//                    log.ballot.info(
//                    '%s: threshold checked: threshold=%s voted=%s minimum_quorum=%s agreed=%d is_passed=%s',
//                    self.node.name,
//                    self.node.quorum.threshold,
//                    sorted(map(lambda x: (x[0], x[1].value), target.items())),
//                    self.node.quorum.minimum_quorum,
//                    len(agreed_votes),
//                    is_passed,
//                    )
                    
                if isPassed {
                        
                    return (State.state(from: stateVal), true)
                }
            }
        }
        
        
        
        return (self.state, false)
    }

    func serializedBallotMessage() -> Data? {

        if let msg = self.message {
            
            if let ballotMessage = BallotMessage(state: self.state, result: self.nodeResult ?? .disagree, messageID: msg.messageID, data: msg.data, node: self.node) {
                
                do {
                    
                    let jsonEncoded = try JSONEncoder().encode(ballotMessage)
                    return jsonEncoded
                    
                } catch {
                    
                    // err
                }
            }
        }
        
        return nil
    }

}
//class AlreadyVotedError(Exception):
//    pass

//class InvalidBallotError(Exception):
//    pass

//class NotExpectedBallotError(Exception):
//    pass

