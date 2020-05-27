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
import ExpandingMenu

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var eMail = ""
    var selectedChat = ""
    var user = CurrentUser.shared.user
    var chatNames = [String]()
    var chats = [Chat]()
    var db = Firestore.firestore()
    var randTryLim = Constants.RAND_TRY_LIM
    
    @IBOutlet weak var chatListTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        generateChatNames()
        getData()
        
        let menuButtonSize: CGSize = CGSize(width: 64.0, height: 64.0)
        let menuButton = ExpandingMenuButton(frame: CGRect(origin: CGPoint.zero,
                                                           size: menuButtonSize),
                                             image: UIImage(systemName: "plus.circle")!,
                                             rotatedImage: UIImage(systemName: "plus.circle")!)
        menuButton.center = CGPoint(x: self.view.bounds.width - 32.0, y: self.view.bounds.height - 72.0)
        view.addSubview(menuButton)

        let item1 = ExpandingMenuItem(size: menuButtonSize,
                                      title: "Random Match!",
                                      image: UIImage(systemName: "arrow.right.square.fill")!,
                                      highlightedImage: UIImage(systemName: "arrow.right.square.fill")!,
                                      backgroundImage: UIImage(systemName: "arrow.right.square.fill"),
                                      backgroundHighlightedImage: UIImage(systemName: "arrow.right.square.fill"))
        { () -> Void in
            print("hmm")
            self.randomMatch()
        }
        
        let item2 = ExpandingMenuItem(size: menuButtonSize, title: "Sign out",
                                      image: UIImage(systemName: "arrow.right.square.fill")!,
                                      highlightedImage: UIImage(systemName: "arrow.right.square.fill")!,
                                      backgroundImage: UIImage(systemName: "arrow.right.square.fill"),
                                      backgroundHighlightedImage: UIImage(systemName: "arrow.right.square.fill"))
        { () -> Void in
            self.signOut(nil)
        }
                
        menuButton.addMenuItems([item1, item2])
    }
    
    func randomMatch() {
        if randTryLim <= 0 {
            makeAlert(title: "Limit Exceed", message: "Random trying limit exceeded")
            return
        }
        
        let randVal = Int.random(in: 0..<Constants.RAND_LIM)
        let randDir = Int.random(in: 0..<1) == 0 ? Constants.RAND_DOWN : Constants.RAND_UP
        
        print(randVal, randDir)
        
        if randDir == Constants.RAND_UP {
            db.collection("userDetail")
                .whereField("random", isGreaterThan: randVal)
                .order(by: "random").getDocuments { (querySnapshot, err) in
                    if let err = err {
                        self.makeAlert(title: "Error!", message: err.localizedDescription )
                    } else {
                        var randUser : User?
                        var createChat = false
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            randUser = User(JSON: data)
                            if (!(self.user.matches?.contains((randUser?.eMail)!))!) &&
                                self.user.eMail != randUser?.eMail {
                                createChat = true
                                break
                            }
                        }
                        if createChat {
                            let chatName = self.generateChatName((randUser?.eMail!)!)
                            self.createChat(chatName, randUser!)
                        } else {
                            self.randTryLim -= 1
                            self.randomMatch()
                        }
                    }
            }
        }
        else {
            db.collection("userDetail")
                .whereField("random", isLessThan: randVal)
                .order(by: "random").getDocuments { (querySnapshot, err) in
                    if let err = err {
                        self.makeAlert(title: "Error!", message: err.localizedDescription )
                    } else {
                        var randUser : User?
                        var createChat = false
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            randUser = User(JSON: data)
                            if (!(self.user.matches?.contains((randUser?.eMail)!))!) &&
                                self.user.eMail != randUser?.eMail {
                                createChat = true
                                break
                            }
                        }
                        if createChat {
                            let chatName = self.generateChatName((randUser?.eMail!)!)
                            self.createChat(chatName, randUser!)
                        } else {
                            self.randTryLim -= 1
                            self.randomMatch()
                        }
                    }
            }
        }
    }
    
    func createChat(_ chatName: String, _ randUser: User) {
        let chat : Chat
        let createDate = Timestamp.init().seconds
        if (user.eMail! < randUser.eMail!) {
            chat = Chat(JSON: [
                "chatName": chatName,
                "username1": user.username!,
                "username2": randUser.username!,
                "avatar1": user.avatarUrl!,
                "avatar2": randUser.avatarUrl!,
                "lastMessage": "You are matched totally random!",
                "basedOn": Constants.BASED_RANDOM,
                "status": Constants.BASED_RANDOM,
                "lastMessageDate": createDate,
                "createDate": createDate,
                "messages": [ChatMessage]()
            ])!
        }
        else {
            chat = Chat(JSON: [
                "chatName": chatName,
                "username1": user.username!,
                "username2": randUser.username!,
                "avatar1": user.avatarUrl!,
                "avatar2": randUser.avatarUrl!,
                "lastMessage": "You are matched totally random!",
                "basedOn": Constants.BASED_RANDOM,
                "status": Constants.BASED_RANDOM,
                "lastMessageDate": createDate,
                "createDate": createDate,
                "messages": [ChatMessage]()
            ])!
        }

        db.collection("chat").document(chatName).setData(chat.toJSON()) { err in
            if let err = err {
                self.makeAlert(title: "Error!", message: err.localizedDescription)
            } else {
                self.updateMatchFields(randUser.eMail!)
                self.chats.append(chat)
                self.chatListTable.reloadData()
            }
        }
    }
    
    func updateMatchFields(_ matchMail: String) {
        db.collection("userDetail").document(user.eMail!).updateData([
            "matches": FieldValue.arrayUnion([matchMail])
        ])
        db.collection("userDetail").document(matchMail).updateData([
            "matches": FieldValue.arrayUnion([self.user.eMail!])
        ])
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
        performSegue(withIdentifier: "toLoginVC", sender: nil)
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
        
        let dateVar = Date.init(timeIntervalSince1970: TimeInterval(chat.lastMessageDate!))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = "h:mm a"
        
        cell.lastMessageLabel.text = chat.lastMessage
        cell.dateLabel.text = dateFormatter.string(from: dateVar)

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
