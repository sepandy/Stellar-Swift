//
//  Ballot.swift
//  Stellar
//
//  Created by Sepand Yadollahifar on 7/24/20.
//  Copyright © 2020 Its3p. All rights reserved.
//

import Foundation

class Ballot: Encodable {
    
    // MARK: - Properties
    
    var state: State
    var stateHistory: [State]
    var name: String
    var message: Message?
    var voted: [Int: [UUID: BallotVoteResult]]
    var isBroadcasted: Bool
    var nodeResult: BallotVoteResult?
    var node: Node
    var application: App
    
//    self.vote_history = dict()
//    self.node_result = node_result
    
    init(name: String, node: Node, state: State, nodeResult: BallotVoteResult?, app: App) {
        
        self.node = node
        self.isBroadcasted = false
        self.message = nil
        self.state = state
        self.nodeResult = nodeResult
        self.stateHistory = []
        self.name = name
        self.voted = [:]
        self.application = app
    }
    
    enum CodingKeys: String, CodingKey {
        case state
        case stateHistory
        case name
        case message
        case voted
        case isBroadcasted
        case nodeResult
        case node
    }
//    
//    required init(from decoder:Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        
//        self.state = try values.decode(State.self, forKey: .state)
//        self.stateHistory = try values.decode([State].self, forKey: .stateHistory)
//        self.name = try values.decode(String.self, forKey: .name)
//        self.voted = try values.decode([Int: [UUID: BallotVoteResult]].self, forKey: .voted)
//        self.isBroadcasted = try values.decode(Bool.self, forKey: .isBroadcasted)
//        self.nodeResult = try values.decode(BallotVoteResult.self, forKey: .nodeResult)
//        self.node = try values.decode(Node.self, forKey: .node)
//        
//        
//    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(state)
        try container.encode(stateHistory)
        try container.encode(name)
        try container.encode(message)
        try container.encode(voted)
        try container.encode(isBroadcasted)
        try container.encode(nodeResult)
        try container.encode(node)
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
                
                return key == node.id
            }
        }
    }
        
    func vote(for node: Node, with result: BallotVoteResult, and state: State) {
        
        if self.state > state {
            
            self.application.logger.debug("Ballot -- \(self.node.name): same message and previous state \(state)")

            return
        }
        
        if !self.voted.contains(where: { (key, _) -> Bool in
            
            return key == state.rawValue
        }) {
            
            self.voted[state.rawValue] = [UUID: BallotVoteResult]()
        }
        
        if self.voted[state.rawValue]!.contains(where: { (key, _) -> Bool in
            
            return key == node.id
        }) {
            
            //# existing vote will be overrided
            self.application.logger.debug("Ballot -- \(self.node.name), \(self): already voted? true")


        }

//         if node.name in self.voted:
//             raise Ballot.AlreadyVotedError('node, %s already voted' % node_name)
//             return

        self.voted[state.rawValue]![node.id] = result
        
        self.application.logger.info("Ballot -- \(self.node.name): \(node ) voted for \(self.message)")
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
                    
                self.application.logger.info("Ballot -- \(self.node.name): threshold checked: threshold=\(self.node.quorum.threshold) minimum_quorum=\(self.node.quorum.minimumQuorum()) agreed=\(agreedVotesCount) is_passed=\(isPassed)")
                    
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

