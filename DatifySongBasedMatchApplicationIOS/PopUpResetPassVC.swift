//
//  PopUpResetPassVC.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 19.05.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import UIKit
import Firebase

class PopUpResetPassVC: UIViewController {
    
    @IBOutlet weak var inputMail: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    
    let EMAIL_REGEX = "^(.+)@([a-zA-Z\\d-]+)\\.([a-zA-Z]+)(\\.[a-zA-Z]+)?$"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        sendBtn.isEnabled = false
        inputMail.addTarget(self, action: #selector(PopUpResetPassVC.textFieldDidChange(_:)), for: .editingChanged)
        sendBtn.addTarget(self, action: #selector(PopUpResetPassVC.sendPassResetMail(_:)), for: .touchUpInside)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let mail = inputMail.text
        let regex = try! NSRegularExpression(pattern: EMAIL_REGEX, options: [])
        let matches = regex.matches(in: mail ?? "", options: [], range: NSRange(location: 0, length: mail?.count ?? 0))

        if (matches.count == 1) {
            sendBtn.isEnabled = true
        } else {
            sendBtn.isEnabled = false
        }
    }

    @objc func sendPassResetMail(_ sender: AnyObject?) {
        sendBtn.isEnabled = false
        
        Auth.auth().sendPasswordReset(withEmail: inputMail.text!) { (err) in
            if (err != nil) {
                self.makeAlert(title: "Error!", message: "Password reset mail could not be sent")
                self.sendBtn.isEnabled = true
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okBtn = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }
    
}
