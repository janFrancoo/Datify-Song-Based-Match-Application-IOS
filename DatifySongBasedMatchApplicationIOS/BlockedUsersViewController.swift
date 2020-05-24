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
    
    var willAdd = [String]()
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
            "blockedMails": user.blockedMails!,
            "matches": FieldValue.arrayUnion(willAdd)
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
            willAdd.append(data[indexPath!.row].mail!)
            data.remove(at: indexPath!.row)
            blockedUsersTable.reloadData()
            user.blockedMails = data
        }
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
        
        cell.usernameLabel.text = data[indexPath.row].username
        cell.reasonLabel.text = data[indexPath.row].reason
        cell.dateLabel.text = "createdate" // data[indexPath.row].createDate date transformations later
        
        return cell
    }
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okBtn = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }
    
}
