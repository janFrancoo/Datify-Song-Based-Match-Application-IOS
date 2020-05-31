//
//  Track.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 31.05.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import Foundation
import ObjectMapper

public struct Track: Mappable {
    
    var userMail: String?
    var trackName: String?
    var artistName: String?
    var uri: String?
    var addDate: Int64?
    
    public init?(map: Map) {

    }

    public mutating func mapping(map: Map) {
        userMail    <- map["userMail"]
        trackName   <- map["trackName"]
        artistName  <- map["artistName"]
        uri         <- map["uri"]
        addDate     <- map["addDate"]
    }
    
}
