//
//  MatchViewController.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 02.06.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class MatchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var trackCover: UIImageView!
    @IBOutlet var currTrackLabel: UILabel!
    @IBOutlet var matchBtn: UIButton!
    @IBOutlet var trackHistoryTable: UITableView!
    
    var tracks: [Track]!
    var db: Firestore!
    var user: User!
    var gCurrTrack: Track?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(trackChanged), name: NSNotification.Name("trackChanged"), object: nil)
        
        tracks = [Track]()
        db = Firestore.firestore()
        user = CurrentUser.shared.user
        
        getData()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        trackHistoryTable.addGestureRecognizer(longPressGesture)
        matchBtn.addTarget(self, action: #selector(MatchViewController.matchBySong(_:)), for: .touchUpInside)
    }
            
    func getData() {
        db.collection("track").document(user.eMail!).collection("list").getDocuments() { (querySnapshot, err) in
            if let err = err {
                self.makeAlert(title: "Error", message: err.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    let track = Track(JSON: document.data())!
                    self.tracks.append(track)
                }
                self.trackHistoryTable.reloadData()
            }
        }
    }
    
    @objc func trackChanged(_ notification: Notification) {
        // prevent saving same tracks
        if let currTrack = notification.userInfo?["currTrack"] as? SPTAppRemoteTrack {
            let createDate = Timestamp.init().seconds

            currTrackLabel.text =
                """
                You are currently listening:
                \(currTrack.name) by \(currTrack.artist.name)
                """
            let imageId = currTrack.imageIdentifier.components(separatedBy: ":")
            let uri = "https://i.scdn.co/image/" + imageId[2]
            trackCover.kf.setImage(with: URL(string: uri))
            
            let track = Track(JSON: [
                "userMail": user.eMail!,
                "trackName": currTrack.name,
                "artistName": currTrack.artist.name,
                "uri": currTrack.uri,
                "addDate": createDate
            ])!
            
            self.gCurrTrack = track
            tracks.append(track)
            trackHistoryTable.reloadData()
            db.collection("track").document(user.eMail!).collection("list")
                .document(track.artistName! + "_" + track.trackName!).setData(track.toJSON())
            db.collection("userDetail").document(user.eMail!).updateData([
                "currTrack": track.artistName! + "___" + track.trackName!,
                "currTrackUri": track.uri!
            ])
        }
    }
    
    @objc func matchBySong(_ sender: AnyObject?) {
        if let currTrack = gCurrTrack {
            var users = [User]()
            db.collection("userDetail")
                .whereField(
                    "currTrack",
                    isEqualTo: currTrack.artistName! + "___" + currTrack.trackName!)
                .getDocuments { (querySnapshot, err) in
                    if let err = err {
                        self.makeAlert(title: "Error!", message: err.localizedDescription)
                    } else {
                        for document in querySnapshot!.documents {
                            let matchUser = User(JSON: document.data())!
                            if matchUser.eMail != self.user.eMail {
                                users.append(matchUser)
                            }
                            // consider the blocked users & already matched users
                        }
                        if !users.isEmpty {
                            self.selectUser(currTrack.trackName! + " - " + currTrack.artistName!, users)
                        }
                    }
            }
        }
    }
    
    func selectUser(_ track: String, _ users: [User]) {
        let popUp = self.storyboard!.instantiateViewController(withIdentifier: "popUpSelectUser")
            as! PopUpSelectUserViewController
        popUp.users = users
        popUp.matchTrack = track
        self.addChild(popUp)
        popUp.view.frame = self.view.frame
        self.view.addSubview(popUp.view)
        popUp.didMove(toParent: self)
    }
    
    func sptConnError() {
        makeAlert(title: "Error!", message: "Spotify connection error")
    }
    
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        let p = longPressGesture.location(in: self.trackHistoryTable)
        let indexPath = self.trackHistoryTable.indexPathForRow(at: p)
        if longPressGesture.state == UIGestureRecognizer.State.began {
            let track = self.tracks[indexPath!.row]
            let docId = track.artistName! + "_" + track.trackName!
            self.db.collection("track").document(user.eMail!).collection("list").document(docId).delete()
            self.tracks.remove(at: indexPath!.row)
            self.trackHistoryTable.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let track = tracks[indexPath.row]
        let trackCell = tableView.dequeueReusableCell(withIdentifier: "trackCell") as! TrackListTableViewCell

        let dateVar = Date.init(timeIntervalSince1970: TimeInterval(track.addDate!))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = "h:mm a"
        
        trackCell.addDateLabel.text = dateFormatter.string(from: dateVar)
        trackCell.artistNameLabel.text = track.artistName
        trackCell.trackNameLabel.text = track.trackName
        
        return trackCell
    }
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okBtn = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }
        
}
