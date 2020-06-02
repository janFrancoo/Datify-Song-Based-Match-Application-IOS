//
//  MatchViewController.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 02.06.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import UIKit

class MatchViewController: UIViewController {

    @IBOutlet weak var sptInfo: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func appRemoteDisconnect() { }
    
    func appRemoteConnecting() { }
    
    func appRemoteConnected() {
        print("SPT Connected! Yey!")
    }
    
    func playerStateChanged(_ playerState: SPTAppRemotePlayerState) {
        print("track.name", playerState.track.name)
        print("track.artist.name", playerState.track.artist.name)
    }
        
}
