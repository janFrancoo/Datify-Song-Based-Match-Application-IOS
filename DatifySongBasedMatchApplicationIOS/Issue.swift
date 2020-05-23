//
//  Issue.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 23.05.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import Foundation
import ObjectMapper

public struct Issue: Mappable {
    
    var mail: String?
    var issue: String?
    var createDate: Int64?
    
    public init?(map: Map) { }

    public mutating func mapping(map: Map) {
        mail        <- map["mail"]
        issue       <- map["issue"]
        createDate  <- map["createDate"]
    }
    
}
