//
//  ChatViewController.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 24.05.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import UIKit
import SQLite3
import Firebase
import Kingfisher

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var chatName: String!
    var matchUsername: String!
    var matchMail: String!
    var matchAvatarUrl: String!
    var db: Firestore!
    var messages: [ChatMessage]!
    var user: User!
    var listener: ListenerRegistration!
    var imgSelected: Bool!
    var localDb: OpaquePointer?
    
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var chatMessagesTable: UITableView!
    @IBOutlet weak var messageInput: UITextField!
    @IBOutlet weak var sendMessageBtn: UIButton!
    @IBOutlet weak var sendFruitBtn: UIButton!
    @IBOutlet weak var chooseImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imgSelected = false
        user = CurrentUser.shared.user
        db = Firestore.firestore()
        messages = [ChatMessage]()
        
        sendMessageBtn.addTarget(self, action: #selector(ChatViewController.sendMessage(_:)), for: .touchUpInside)
        sendFruitBtn.addTarget(self, action: #selector(ChatViewController.sendFruit(_:)), for: .touchUpInside)
        usernameBtn.addTarget(self, action: #selector(ChatViewController.goToUserProfile(_:)), for: .touchUpInside)
        messageInput.addTarget(self, action: #selector(ChatViewController.textFieldDidChange(_:)), for: .editingChanged)
        
        sendMessageBtn.isEnabled = false
        chooseImageView.isUserInteractionEnabled = true
        let gestRecognizer = UITapGestureRecognizer(target: self, action: #selector(choosePic))
        chooseImageView.addGestureRecognizer(gestRecognizer)
        
        localDbSetup()
        getFromLocalDb()
        listenCloud()
        updateHeader()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if listener != nil {
            listener.remove()
        }
        
        removeRedundantMessagesFromCloud()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let message = messageInput.text {
            if message != "" || imgSelected == true {
                sendMessageBtn.isEnabled = true
            } else {
                sendMessageBtn.isEnabled = false
            }
        } else {
            sendMessageBtn.isEnabled = false
        }
    }
    
    func localDbSetup() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory,
                                                   in: .userDomainMask,
                                                   appropriateFor: nil,
                                                   create: false).appendingPathComponent(Constants.DB_NAME)
        if sqlite3_open(fileURL.path, &localDb) != SQLITE_OK {
            makeAlert(title: "Error!", message: "Local db conn error")
        } else {
            let query = """
                        CREATE TABLE IF NOT EXISTS \(Constants.TABLE_MESSAGES) (chatName VARCHAR,
                        sender VARCHAR, message VARCHAR, sendDate LONG, read INT, imgUrl VARCHAR, fruitId INT,
                        PRIMARY KEY (message, sendDate))
                        """
            var createTableStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(localDb, query, -1, &createTableStatement, nil) == SQLITE_OK {
                if sqlite3_step(createTableStatement) != SQLITE_DONE {
                    makeAlert(title: "Error!", message: "Create table error")
                }
            } else {
                makeAlert(title: "Error!", message: "Create table statement error")
            }
            sqlite3_finalize(createTableStatement)
        }
    }
    
    func getFromLocalDb() {
        // FIXME: Order by date
        let query = "SELECT * FROM \(Constants.TABLE_MESSAGES)"
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(localDb, query, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let chatNameFromLocal = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                if chatNameFromLocal == chatName {
                    let chatMessage = ChatMessage(JSON: [
                        "sender": String(describing: String(cString: sqlite3_column_text(queryStatement, 1))),
                        "message": String(describing: String(cString: sqlite3_column_text(queryStatement, 2))),
                        "imgUrl": String(describing: String(cString: sqlite3_column_text(queryStatement, 5))),
                        "transmitted": true,
                        "read": sqlite3_column_int(queryStatement, 4) == 1 ? true : false,
                        "fruitId": sqlite3_column_int(queryStatement, 6),
                        "sendDate": sqlite3_column_int(queryStatement, 3)
                    ])!
                    messages.append(chatMessage)
                }
            }
            chatMessagesTable.reloadData()
        }
        sqlite3_finalize(queryStatement)
    }
    
    func listenCloud() {
        listener = db.collection("chat").document(chatName).collection("message")
            .addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Listen error")
                return
            }
            snapshot.documentChanges.forEach { diff in
                if diff.type == .added {
                    let chatMessage = ChatMessage(JSON: diff.document.data())!
                    if !self.messages.contains(chatMessage) {
                        self.messages.append(chatMessage)
                        self.chatMessagesTable.reloadData()
                        if chatMessage.sender != self.user.username {
                            self.db.collection("chat").document(self.chatName)
                                .collection("message").document(diff.document.documentID).updateData([
                                    "read": true
                                ])
                        }
                        self.writeToLocalDb(chatMessage)
                    }
                }
                // FIXME: add type .changed for read -> true
            }
        }
    }
    
    func writeToLocalDb(_ chatMessage: ChatMessage) {
        let insertStatementString = """
                                    REPLACE INTO \(Constants.TABLE_MESSAGES)
                                    (chatName, sender, message, sendDate, read, imgUrl, fruitId) VALUES
                                    (?, ?, ?, ?, \(chatMessage.read! ? 1 : 0), ?, \(chatMessage.fruitId!))
                                    """
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(localDb, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (chatName as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (chatMessage.sender! as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (chatMessage.message! as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 4, Int32(chatMessage.sendDate!))
            sqlite3_bind_text(insertStatement, 5, (chatMessage.imgUrl! as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) != SQLITE_DONE {
                makeAlert(title: "Error!", message: "Write to local error")
            }
        } else {
            makeAlert(title: "Error!", message: "Replace into statement error")
        }
        sqlite3_finalize(insertStatement)
    }
    
    func updateLastMessage(_ lastMessage: String, _ lastMessageDate: Int64) {
        db.collection("chat").document(chatName).updateData([
            "lastMessage": lastMessage,
            "lastMessageDate": lastMessageDate
        ])
    }
    
    func removeRedundantMessagesFromCloud() {
        db.collection("chat").document(chatName).collection("message")
            .whereField("sender", isEqualTo: user.username!)
            .whereField("read", isEqualTo: true)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    self.makeAlert(title: "Error!", message: err.localizedDescription)
                } else {
                    for document in querySnapshot!.documents {
                      document.reference.delete()
                    }
                }
            }
    }
    
    func updateHeader() {
        let url = URL(string: matchAvatarUrl)
        userAvatar.kf.setImage(with: url)
        usernameBtn.setTitle(matchUsername, for: .normal)
    }
    
    @objc func sendMessage(_ sender: AnyObject?) {
        let message = messageInput.text!
        messageInput.text = ""
        let createDate = Timestamp.init().seconds
        
        if imgSelected == true {
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let mediaFolder = storageRef.child("chatImages")
            
            var chatMessageWithoutImg = ChatMessage(JSON: [
                "sender": self.user.username!,
                "message": message,
                "imgUrl": "",
                "transmitted": false,
                "read": false,
                "fruitId": 0,
                "sendDate": createDate
            ])!
            
            messages.append(chatMessageWithoutImg)
            chatMessagesTable.reloadData()
  
            if let data = chooseImageView.image?.jpegData(compressionQuality: 0.5) {
                let uuid = UUID().uuidString
                let imageRef = mediaFolder.child("\(uuid).jpg")
                imageRef.putData(data, metadata: nil) { (metadata, error) in
                    if let err = error {
                        self.makeAlert(title: "Error", message: err.localizedDescription)
                    } else {
                        imageRef.downloadURL { (url, error) in
                            if let err = error {
                                self.makeAlert(title: "Error", message: err.localizedDescription)
                            } else {
                                self.imgSelected = false
                                let imageURL = url?.absoluteString
                                chatMessageWithoutImg.imgUrl = imageURL
                                chatMessageWithoutImg.transmitted = true
                                self.db.collection("chat").document(self.chatName).collection("message").addDocument(data: chatMessageWithoutImg.toJSON()) { err in
                                    if let err = err {
                                        self.makeAlert(title: "Error!", message: err.localizedDescription)
                                    } else {
                                        self.updateLastMessage(chatMessageWithoutImg.message!, chatMessageWithoutImg.sendDate!)
                                        for i in stride(from: self.messages.count - 1, through: 0, by: -1) {
                                            if self.messages[i].sendDate == chatMessageWithoutImg.sendDate
                                            && self.messages[i].sender == chatMessageWithoutImg.sender {
                                                self.messages[i].imgUrl = imageURL
                                                self.messages[i].transmitted = true
                                                break
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            let chatMessageNotTransmitted = ChatMessage(JSON: [
                "sender": user.username!,
                "message": message,
                "imgUrl": "",
                "transmitted": false,
                "read": false,
                "fruitId": 0,
                "sendDate": createDate
            ])!
            
            messages.append(chatMessageNotTransmitted)
            chatMessagesTable.reloadData()
            
            var chatMessageTransmitted = chatMessageNotTransmitted
            chatMessageTransmitted.transmitted = true
            
            db.collection("chat").document(chatName).collection("message").addDocument(data: chatMessageTransmitted.toJSON()) { err in
                if let err = err {
                    self.makeAlert(title: "Error!", message: err.localizedDescription)
                } else {
                    self.updateLastMessage(chatMessageTransmitted.message!, chatMessageTransmitted.sendDate!)
                    for i in stride(from: self.messages.count - 1, through: 0, by: -1) {
                        if self.messages[i].sendDate == chatMessageTransmitted.sendDate
                        && self.messages[i].sender == chatMessageTransmitted.sender {
                            self.messages[i].transmitted = true
                            break
                        }
                    }
                }
            }
        }
    }
    
    @objc func sendFruit(_ sender: AnyObject?) {
        // updateLastMessage
    }
    
    @objc func choosePic(_ sender: AnyObject?) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        chooseImageView.image = info[.originalImage] as? UIImage
        imgSelected = true
        self.dismiss(animated: true, completion: nil)
    }

    // sync listening
    
    @objc func goToUserProfile(_ sender: AnyObject?) {
        self.performSegue(withIdentifier: "toProfileVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let leftCell = tableView.dequeueReusableCell(withIdentifier: "messageCellLeft") as! ChatMessageLeftTableViewCell
        let rightCell = tableView.dequeueReusableCell(withIdentifier: "messageCellRight") as! ChatMessageRightTableViewCell
        
        let dateVar = Date.init(timeIntervalSince1970: TimeInterval(message.sendDate!))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = "h:mm a"
                
        if message.sender == user.username {
            rightCell.messageLabel.text = message.message
            rightCell.dateLabel.text = dateFormatter.string(from: dateVar)
            if message.imgUrl != "" {
                rightCell.sentImage.kf.setImage(with: URL(string: message.imgUrl!))
            } else if message.fruitId != 0 {
                switch message.fruitId {
                case Constants.FRUIT_LEMON:
                    print("lemon") // change later
                case Constants.FRUIT_WATERMELON:
                    print("waterlemon") // change later
                default:
                    print("default") // change later
                }
            }
            if message.transmitted == true {
                //
            }
            if message.read == true {
                //
            }
            return rightCell
        } else {
            leftCell.messageLabel.text = message.message
            leftCell.dateLabel.text = dateFormatter.string(from: dateVar)
            if message.imgUrl != "" {
                leftCell.sentImage.kf.setImage(with: URL(string: message.imgUrl!))
            }
            return leftCell
        }
    }
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okBtn = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProfileVC" {
            let destinationVC = segue.destination as! ProfileViewController
            destinationVC.mail = matchMail
            destinationVC.avatarUrl = matchAvatarUrl
            destinationVC.chatName = chatName
            destinationVC.username = matchUsername
        }
    }

}
