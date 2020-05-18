//
//  Block.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 18.05.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import Foundation
import ObjectMapper

public struct Block: Mappable {
    
    var mail: String?
    var username: String?
    var avatarUrl: String?
    var reason: String?
    var createDate: Int64?
    
    public init?(map: Map) {

    }

    public mutating func mapping(map: Map) {
        mail        <- map["mail"]
        username    <- map["username"]
        avatarUrl   <- map["avatarUrl"]
        reason      <- map["reason"]
        createDate  <- map["createDate"]
    }
    
}
