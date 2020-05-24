//
//  Chat.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 24.05.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import Foundation
import ObjectMapper

public struct Chat: Mappable, Equatable {
    
    var chatName: String?
    var username1: String?
    var username2: String?
    var avatar1: String?
    var avatar2: String?
    var lastMessage: String?
    var basedOn: Int?
    var status: Int?
    var lastMessageDate: Int64?
    var createDate: Int64?
    var messages: [ChatMessage]?
    
    public init?(map: Map) {

    }

    public mutating func mapping(map: Map) {
        chatName    <- map["chatName"]
        username1   <- map["username1"]
        username2   <- map["username2"]
        avatar1     <- map["avatar1"]
        avatar2     <- map["avatar2"]
        lastMessage <- map["lastMessage"]
        basedOn     <- map["basedOn"]
        status      <- map["status"]
        lastMessageDate <- map["lastMessageDate"]
        createDate      <- map["createDate"]
        messages        <- map["messages"]
    }
    
}

extension Chat {
    public static func == (c1: Chat, c2: Chat) -> Bool {
        return c1.chatName == c2.chatName
    }
}
