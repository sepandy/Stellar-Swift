//
//  State.swift
//  Stellar
//
//  Created by Sepand Yadollahifar on 7/26/20.
//  Copyright © 2020 Its3p. All rights reserved.
//

import Foundation

enum State: Int, Codable {
    case none = 0
    case initialize = 1
    case sign = 2
    case accept = 3
    case allConfirm = 4
    
    static func state(from val: Int) -> State {
        
        switch val {
            case 0:
                return .none
            case 1:
                return .initialize
            case 2:
                return .sign
            case 3:
                return .accept
            case 4:
                return .allConfirm
            default:
                return .none
        }
    }
}

extension State {
    
    static func >(lhs: State, rhs: State) -> Bool {
        
        if lhs.rawValue > rhs.rawValue {
             
            return true
        }
        
        return false
    }
    
    static func <(lhs: State, rhs: State) -> Bool {
        
        if lhs.rawValue < rhs.rawValue {
             
            return true
        }
        
        return false
    }
    
    static func >=(lhs: State, rhs: State) -> Bool {
        
        if lhs.rawValue >= rhs.rawValue {
             
            return true
        }
        
        return false
    }
    
    static func <=(lhs: State, rhs: State) -> Bool {
        
        if lhs.rawValue <= rhs.rawValue {
             
            return true
        }
        
        return false
    }
    
    static func ==(lhs: State, rhs: State) -> Bool {
        
        if lhs.rawValue == rhs.rawValue {
             
            return true
        }
        
        return false
    }
}

extension State {
    
    func getNext() -> State? {
        
        if self.rawValue < 3 {
            
            return State.state(from: self.rawValue + 1)
        }
        
        return nil
    }
    
    func isNext(state: State) -> Bool {
        
        return state.rawValue == self.rawValue + 1 
    }
}
