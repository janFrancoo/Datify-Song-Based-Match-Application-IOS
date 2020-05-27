//
//  BlockedUsersViewController.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 23.05.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class BlockedUsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user = CurrentUser.shared.user
    var db = Firestore.firestore()
    var data = [Block]()
    
    @IBOutlet weak var blockedUsersTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        data = user.blockedMails!
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        blockedUsersTable.addGestureRecognizer(longPressGesture)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        db.collection("userDetail").document(user.eMail!).updateData([
            "blockedMails": user.blockedMails!
        ]) { err in
            if let err = err {
                self.makeAlert(title: "Error", message: err.localizedDescription )
            }
        }
    }
    
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        let p = longPressGesture.location(in: blockedUsersTable)
        let indexPath = blockedUsersTable.indexPathForRow(at: p)
        if longPressGesture.state == UIGestureRecognizer.State.began {
            let chatName = generateChatName(data[indexPath!.row].mail!)
            db.collection("chat").document(chatName).updateData([
                "status": Constants.STATUS_CLOSED
            ]) { err in
                if let err = err {
                    self.makeAlert(title: "Error", message: err.localizedDescription )
                }
                else {
                    self.data.remove(at: indexPath!.row)
                    self.blockedUsersTable.reloadData()
                    self.user.blockedMails = self.data
                }
            }
        }
    }
    
    func generateChatName(_ matchMail: String) -> String {
        var chatName = ""
        if user.eMail! < matchMail {
            chatName = user.eMail! + "_" + matchMail
        } else {
            chatName = matchMail + "_" + user.eMail!
        }
        return chatName
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "blockedUser") as! BlockedUserTableViewCell
        
        if data[indexPath.row].avatarUrl != "default" {
            let url = URL(string: data[indexPath.row].avatarUrl!)
            cell.avatarImageView.kf.setImage(with: url)
        }
        
        let dateVar = Date.init(timeIntervalSinceNow: TimeInterval(data[indexPath.row].createDate!))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = "dd.MM"
        
        cell.usernameLabel.text = data[indexPath.row].username
        cell.reasonLabel.text = data[indexPath.row].reason
        cell.dateLabel.text = dateFormatter.string(from: dateVar)

        return cell
    }
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okBtn = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }
    
}
