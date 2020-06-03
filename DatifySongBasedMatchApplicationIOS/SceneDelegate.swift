//
//  SceneDelegate.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 17.05.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {

    static private let kAccessTokenKey = "access-token-key"
    private let redirectUri = URL(string: Constants.REDIRECT_URI)!
    private let clientIdentifier = Constants.CLIENT_ID

    var window: UIWindow?

    lazy var appRemote: SPTAppRemote = {
        let configuration = SPTConfiguration(clientID: self.clientIdentifier, redirectURL: self.redirectUri)
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()

    var accessToken = UserDefaults.standard.string(forKey: kAccessTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: SceneDelegate.kAccessTokenKey)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }

        let parameters = appRemote.authorizationParameters(from: url);

        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = access_token
            self.accessToken = access_token
        } else if let _ = parameters?[SPTAppRemoteErrorDescriptionKey] {
            // err
        }

    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        connect();
    }

    func sceneWillResignActive(_ scene: UIScene) { }

    func connect() {
       appRemote.connect()
       
       if (!appRemote.isConnected) {
           appRemote.authorizeAndPlayURI("")
       }
    }
    
    var currTrack: SPTAppRemoteTrack?
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        if currTrack != nil && currTrack!.name != playerState.track.name {
            NotificationCenter.default.post(
                name: NSNotification.Name(rawValue: "trackChanged"),
                object: nil,
                userInfo: ["currTrack": playerState.track])
        }
        
        currTrack = playerState.track
    }
    
    // MARK: AppRemoteDelegate
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.appRemote = appRemote
        
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
        })
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("err")
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("err")
    }
    
}
