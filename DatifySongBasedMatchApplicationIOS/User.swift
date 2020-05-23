//
//  User.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 18.05.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import Foundation
import ObjectMapper

struct User: Mappable {
    
    var eMail: String?
    var username: String?
    var avatarUrl: String?
    var bio: String?
    var gender: String?
    var currTrack: String?
    var currTrackUri: String?
    
    var random: Int?
    var createDate: Int64?
    var currTrackIntervation: Bool?

    var matches: [String]?
    var blockedMails: [Block]?

    init () { }
    init?(map: Map) { }

    mutating func mapping(map: Map) {
        eMail                   <- map["eMail"]
        username                <- map["username"]
        avatarUrl               <- map["avatarUrl"]
        bio                     <- map["bio"]
        gender                  <- map["gender"]
        currTrack               <- map["currTrack"]
        currTrackUri            <- map["currTrackUri"]
        random                  <- map["random"]
        createDate              <- map["createDate"]
        currTrackIntervation    <- map["currTrackIntervation"]
        matches                 <- map["matches"]
        blockedMails            <- map["blockedMails"]
    }
    
}
