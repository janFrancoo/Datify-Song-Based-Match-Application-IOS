//
//  ChatMessage.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 24.05.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import Foundation
import ObjectMapper

public struct ChatMessage: Mappable, Equatable {
        
    var sender: String?
    var message: String?
    var imgUrl: String?
    var transmitted: Bool?
    var read: Bool?
    var fruitId: Int?
    var sendDate: Int64?
    
    public init?(map: Map) {

    }

    public mutating func mapping(map: Map) {
        sender          <- map["sender"]
        message         <- map["message"]
        imgUrl          <- map["imgUrl"]
        transmitted     <- map["transmitted"]
        read            <- map["read"]
        fruitId         <- map["fruitId"]
        sendDate        <- map["sendDate"]
    }
    
}

extension ChatMessage {
    public static func == (c1: ChatMessage, c2: ChatMessage) -> Bool {
        return c1.sendDate == c2.sendDate
    }
}
