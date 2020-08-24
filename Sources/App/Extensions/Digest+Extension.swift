//
//  Digest+Extension.swift
//  PoS-I1
//
//  Created by Sepand Yadollahifar

import Foundation
import CryptoKit

extension Digest {
    
    var bytes: [UInt8] { Array(makeIterator()) }
    var data: Data { Data(bytes) }

    var hexStr: String {
        bytes.map { String(format: "%02X", $0) }.joined()
    }
    
}
