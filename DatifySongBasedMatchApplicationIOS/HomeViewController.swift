//
//  HomeViewController.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 18.05.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var eMail = ""
    var selectedChat = ""
    var user = CurrentUser.shared.user
    var chatNames = [String]()
    var chats = [Chat]()
    var db = Firestore.firestore()
    
    @IBOutlet weak var tmpSignOut: UIButton!
    @IBOutlet weak var tmpSettingsBtn: UIButton!
    @IBOutlet weak var chatListTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        generateChatNames()
        getData()
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        tmpSignOut.addTarget(self, action: #selector(HomeViewController.signOut(_:)), for: .touchUpInside)
        tmpSettingsBtn.addTarget(self, action: #selector(HomeViewController.goToSettings(_:)), for: .touchUpInside)
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
    
    func generateChatNames() {
        for matchMail in user.matches! {
            let chatName = generateChatName(matchMail)
            chatNames.append(chatName)
        }
    }
    
    func getData() {
        if chatNames.isEmpty {
            return
        }
        
        db.collection("chat").whereField(FieldPath.documentID(), in: chatNames).addSnapshotListener(includeMetadataChanges: true) { (snapshot, err) in
            if err != nil {
                self.makeAlert(title: "Error", message: err?.localizedDescription ?? "Chat list error")
            } else {
                for doc in snapshot!.documents {
                    let chat = Chat(JSON: doc.data())
                    if !self.chats.contains(chat!) {
                        self.chats.append(chat!)
                        self.chatListTable.reloadData()
                    }
                }
            }
        }
    }
    
    @objc func signOut(_ sender: AnyObject?) {
        try! Auth.auth().signOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func goToSettings(_ sender: AnyObject?) {
        self.performSegue(withIdentifier: "toSettingsVC", sender: nil )
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatListCell") as! ChatListTableViewCell
        
        let chat = chats[indexPath.row]
        if chat.username1 == user.username {
            if chat.avatar2 != "default" {
                let url = URL(string: chat.avatar2!)
                cell.avatarImageView.kf.setImage(with: url)
            }
            cell.usernameLabel.text = chat.username2
        } else {
            if chat.avatar1 != "default" {
                let url = URL(string: chat.avatar1!)
                cell.avatarImageView.kf.setImage(with: url)
            }
            cell.usernameLabel.text = chat.username1
        }
        
        cell.lastMessageLabel.text = chat.lastMessage
        cell.dateLabel.text = "createDate" // fix date later - lastMessageDate

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedChat = chats[indexPath.row].chatName!
        self.performSegue(withIdentifier: "toChatVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toSettingsVC") {
            let destinationVC = segue.destination as! SettingsViewController
            destinationVC.backNav = true
        } else if (segue.identifier == "toChatVC") {
            let destinationVC = segue.destination as! ChatViewController
            destinationVC.chatName = selectedChat
        }
    }
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okBtn = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }

}
