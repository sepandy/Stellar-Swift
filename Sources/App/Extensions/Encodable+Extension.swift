//
//  Encodable+Extension.swift
//  Stellar
//
//  Created by Sepand Yadollahifar on 7/27/20.
//  Copyright © 2020 Its3p. All rights reserved.
//

import Foundation

extension Encodable {

    var dict : [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else { return nil }
        return json
    }
}
