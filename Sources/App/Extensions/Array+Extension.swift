//
//  File.swift
//  
//
//  Created by Sepand Yadollahifar on 8/24/20.
//

import Foundation

extension Array where Element == UInt8 {
    var data : Data{
        return Data(self)
    }
}
