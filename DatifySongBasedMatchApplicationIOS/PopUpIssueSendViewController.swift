//
//  PopUpIssueSendViewController.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 23.05.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import UIKit
import Firebase

class PopUpIssueSendViewController: UIViewController {
    
    var db = Firestore.firestore()
    var user = CurrentUser.shared.user
    
    @IBOutlet weak var inputIssue: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var alertView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertView.layer.cornerRadius = 16
        alertView.clipsToBounds = true
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        sendBtn.isEnabled = false
        inputIssue.addTarget(self, action: #selector(PopUpIssueSendViewController.textFieldDidChange(_:)), for: .editingChanged)
        sendBtn.addTarget(self, action: #selector(PopUpIssueSendViewController.sendIssue(_:)), for: .touchUpInside)
        cancelBtn.addTarget(self, action: #selector(PopUpIssueSendViewController.cancel(_:)), for: .touchUpInside)
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        let issue = inputIssue.text ?? ""
        
        if issue.count > 0 {
            sendBtn.isEnabled = true
        } else {
            sendBtn.isEnabled = false
        }
    }

    @objc func sendIssue(_ sender: AnyObject?) {
        sendBtn.isEnabled = false
        
        let createDate = Timestamp.init().seconds
        let issue = Issue(JSON: [
            "mail": self.user.eMail!,
            "issue": self.inputIssue.text!,
            "createDate": createDate,
        ])
        
        self.db.collection("report").addDocument(data: issue!.toJSON()) { (err) in
            if (err != nil) {
                self.sendBtn.isEnabled = true
                self.makeAlert(title: "Error!", message: err?.localizedDescription ?? "Issue sending error")
            } else {
                self.makeAlert(title: "Successfull", message: "Your report has been sent!")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func cancel(_ sender: Any) {
        removeAnimate()
    }
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 0.0
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }, completion: { (finished: Bool) in
            if finished {
                self.view.removeFromSuperview()
            }
        })
    }
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okBtn = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }
    
}
