//
//  MatchViewController.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 31.05.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import UIKit

class MatchViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        SPTAppRemote.checkIfSpotifyAppIsActive({ active in
            if active {
                // Prompt the user to connect Spotify here
            }
        })
    }
    
}
