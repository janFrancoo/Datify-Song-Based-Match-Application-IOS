//
//  ChatMessage.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 24.05.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import Foundation
import ObjectMapper

public struct ChatMessage: Mappable {
    
    /*
    private String sender, message, imgUrl;
    private boolean transmitted, read;
    private long sendDate;
    private int fruitId = 0;
    */
    
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
        sender          <- map["mail"]
        message         <- map["username"]
        imgUrl          <- map["avatarUrl"]
        transmitted     <- map["reason"]
        read            <- map["createDate"]
        fruitId         <- map["fruitId"]
        sendDate        <- map["sendDate"]
    }
    
}
