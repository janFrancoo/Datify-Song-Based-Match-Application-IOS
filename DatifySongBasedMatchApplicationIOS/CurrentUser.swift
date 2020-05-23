//
//  CurrentUser.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 23.05.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import Foundation

class CurrentUser {
    
    static let shared = CurrentUser()
    
    private init() { }
    
    var user = User()
    
    func setUser(user: User) {
        self.user = user
    }
    
}
