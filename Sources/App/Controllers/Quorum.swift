//
//  Quorum.swift
//  Stellar
//
//  Created by Sepand Yadollahifar on 7/22/20.
//  Copyright © 2020 Its3p. All rights reserved.
//

import Foundation

class Quorum: Codable {
    
    // MARK: - Properties
    
    var validators: [Node]
    var threshold: Int
    
    init(threshold: Int, validators: [Node]) {
        
        
        // MARK: - check if thresh hold is between 0 and 100 (%)
        
        self.threshold = threshold > 100 ? 100 : threshold < 0 ? 1 : threshold
        self.validators = validators
    }

    func contains(node: Node) -> Bool {
        
        return self.validators.contains { (validator) -> Bool in
            
            return node == validator
        }
    }

    func remove(node: Node) -> Bool {

        if self.validators.contains(where: { (validator) -> Bool in
            
            return node == validator
        }) {
            
            self.validators.removeAll { (validator) -> Bool in

                return node == validator
            }
            
            return true
        }
        
        return false
    }

    func minimumQuorum() -> Int {
        
        let res = Int(round(Double(self.validators.count + 1) * (Double(self.threshold) / 100)))
        
        return res
    }

}

extension Quorum {
    
    static func ==(lhs: Quorum, rhs: Quorum) -> Bool {
        
        if lhs.threshold == rhs.threshold && lhs.validators == rhs.validators {
            
            return true
        }
        
        return false
    }
    
    static func !=(lhs: Quorum, rhs: Quorum) -> Bool {
        
        if lhs.threshold != rhs.threshold || lhs.validators != rhs.validators {
            
            return true
        }
        
        return false
    }
}
