//
//  ProfileViewController.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 30.05.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var mail: String!
    var username: String!
    var avatarUrl: String!
    var chatName: String!
    var db: Firestore!
    var user: User!
    var tracks: [Track]!
    var profileUser: User!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var currTrackLabel: UILabel!
    @IBOutlet weak var trackHistTable: UITableView!
    @IBOutlet weak var blockBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = CurrentUser.shared.user
        db = Firestore.firestore()
        tracks = [Track]()
        
        getUserData()
        getTrackHistory()
        
        avatarImageView.kf.setImage(with: URL(string: avatarUrl))
        usernameLabel.text = username
        
        blockBtn.addTarget(self, action: #selector(ProfileViewController.blockUser(_:)), for: .touchUpInside)
    }
    
    func getUserData() {
        db.collection("userDetail").document(mail).getDocument { (document, error) in
            if let err = error {
                self.makeAlert(title: "Error!", message: err.localizedDescription)
            } else if let doc = document, doc.exists {
                self.profileUser = User(JSON: doc.data()!)!
                self.currTrackLabel.text = self.profileUser.currTrack
            }
        }
    }
    
    func getTrackHistory() {
        db.collection("track").document(mail).collection("list")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    self.makeAlert(title: "Error!", message: err.localizedDescription)
                } else {
                    for document in querySnapshot!.documents {
                        let track = Track(JSON: document.data())!
                        self.tracks.append(track)
                    }
                    self.trackHistTable.reloadData()
                }
        }
    }
    
    @objc func blockUser(_ sender: AnyObject?) {
        // TODO: PopUp with reason text input
        
        let createDate = Timestamp.init().seconds
        let block = Block(JSON: [
            "mail": mail!,
            "username": username!,
            "avatarUrl": avatarUrl!,
            "reason": "ios",
            "createDate": createDate
        ])!
                
        db.collection("userDetail").document(user.eMail!).updateData([
            "blockedMails": FieldValue.arrayUnion([block.toJSON()])
        ]) { err in
            if let err = err {
                self.makeAlert(title: "Error", message: err.localizedDescription)
            } else {
                self.db.collection("chat").document(self.chatName).updateData([
                    "status": Constants.STATUS_CLOSED
                ]) { err in
                    if let err = err {
                        self.makeAlert(title: "Error", message: err.localizedDescription)
                    } else {
                        self.performSegue(withIdentifier: "toHomeVC", sender: nil)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell") as! TrackListTableViewCell
        let track = tracks[indexPath.row]
        
        cell.trackNameLabel.text = track.trackName
        cell.artistNameLabel.text = track.artistName
        
        let dateVar = Date.init(timeIntervalSinceNow: TimeInterval(track.addDate!))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = "dd.MM"
        
        cell.addDateLabel.text = dateFormatter.string(from: dateVar)

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toHomeVC") {
            let _ = segue.destination as! HomeViewController
        }
    }
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okBtn = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }

}
