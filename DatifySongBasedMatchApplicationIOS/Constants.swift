//
//  Constants.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 26.05.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import Foundation

struct Constants {
    
    // Random
    static let RAND_LIM = 10000
    static let RAND_UP = 1
    static let RAND_DOWN = 0
    
    // Chat
    static let BASED_RANDOM = 0
    static let BASED_SONG = 1
    static let STATUS_NEW = 0
    static let STATUS_CLOSED = 1
    static let RAND_TRY_LIM = 5
    
    // Fruit
    static let FRUIT_LEMON = 1
    static let FRUIT_WATERMELON = 2
    
    // SQLite
    static let DB_NAME = "datifyDB.sqlite"
    static let TABLE_MESSAGES = "messages"
    
    // Spotify
    static let CLIENT_ID = "fb4680b5b1384bcaaf3febd991797ecc"
    static let REDIRECT_URI = "com.janfranco.DatifySongBasedMatchApplication://callback"
    
}
