//
//  RegisterViewController.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 18.05.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import UIKit
import Firebase
import ObjectMapper

class RegisterViewController: UIViewController {
    
    var db: Firestore!
    
    @IBOutlet weak var inputMail: UITextField!
    @IBOutlet weak var inputUsername: UITextField!
    @IBOutlet weak var inputPass: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    
    let EMAIL_REGEX = "^(.+)@([a-zA-Z\\d-]+)\\.([a-zA-Z]+)(\\.[a-zA-Z]+)?$"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()

        registerBtn.isEnabled = false
        inputMail.addTarget(self, action: #selector(ViewController.textFieldDidChange(_:)), for: .editingChanged)
        inputUsername.addTarget(self, action: #selector(ViewController.textFieldDidChange(_:)), for: .editingChanged)
        inputPass.addTarget(self, action: #selector(ViewController.textFieldDidChange(_:)), for: .editingChanged)
        registerBtn.addTarget(self, action: #selector(RegisterViewController.register(_:)), for: .touchUpInside)
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (inputPass.text?.count ?? 0 >= 5 && inputUsername.text?.count ?? 0 >= 5) {
            let mail = inputMail.text
            let regex = try! NSRegularExpression(pattern: EMAIL_REGEX, options: [])
            let matches = regex.matches(in: mail ?? "", options: [], range: NSRange(location: 0, length: mail?.count ?? 0))

            if (matches.count == 1) {
                registerBtn.isEnabled = true
            } else {
                registerBtn.isEnabled = false
            }
        } else {
            registerBtn.isEnabled = false
        }
    }
    
    @objc func register(_ sender : AnyObject?) {
        registerBtn.isEnabled = false
        
        db.collection("userDetail").whereField("username", isEqualTo: inputUsername.text!)
            .getDocuments { (querySnapshot, err) in
                if (err != nil) {
                    self.makeAlert(title: "Error!", message: "Registration error")
                } else {
                    if (querySnapshot?.isEmpty ?? true) {
                        Auth.auth().createUser(withEmail: self.inputMail.text!, password: self.inputPass.text!) { (_, err) in
                            if (err != nil) {
                                self.makeAlert(title: "Error!", message: "Registration error")
                                self.registerBtn.isEnabled = true
                            } else {
                                self.saveUser()
                            }
                        }
                    } else {
                        self.makeAlert(title: "Error!", message: "This username is used")
                    }
                }
        }
    }
    
    func saveUser() {
        let createDate = Timestamp.init().seconds
        let user = User(JSON: [
            "eMail": self.inputMail.text!,
            "username": self.inputUsername.text!,
            "avatarUrl": "default",
            "bio": "",
            "gender": "",
            "currTrack": "",
            "currTrackUri": "",
            "random": Int.random(in: 0..<10000),
            "createDate": createDate,
            "currTrackIntervation": false,
            "matches": [],
            "blockedMails": []
        ])
        
        self.db.collection("userDetail").document(self.inputMail.text!).setData(user!.toJSON()) { (err) in
            if (err != nil) {
                self.registerBtn.isEnabled = true
                self.makeAlert(title: "Error!", message: "User registration error")
                Auth.auth().currentUser?.delete()
            } else {
                CurrentUser.shared.user = user!
                self.performSegue(withIdentifier: "toSettingsVC", sender: nil )
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toSettingsVC") {
            _ = segue.destination as! SettingsViewController
        }
    }
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okBtn = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }

}
