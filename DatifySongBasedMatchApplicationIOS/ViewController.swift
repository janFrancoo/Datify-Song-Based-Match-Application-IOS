//
//  ViewController.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 17.05.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var inputMail: UITextField!
    @IBOutlet weak var inputPass: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var resetPassBtn: UIButton!
    @IBOutlet weak var toggleSecureBtn: UIButton!
    
    var db: Firestore!
    var show = false
    let EMAIL_REGEX = "^(.+)@([a-zA-Z\\d-]+)\\.([a-zA-Z]+)(\\.[a-zA-Z]+)?$"
    
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        loginBtn.isEnabled = false
        inputMail.addTarget(self, action: #selector(ViewController.textFieldDidChange(_:)), for: .editingChanged)
        inputPass.addTarget(self, action: #selector(ViewController.textFieldDidChange(_:)), for: .editingChanged)
        loginBtn.addTarget(self, action: #selector(ViewController.login(_:)), for: .touchUpInside)
        resetPassBtn.addTarget(self, action: #selector(ViewController.resetPass(_:)), for: .touchUpInside)
        toggleSecureBtn.addTarget(self, action: #selector(ViewController.toggleSecure(_:)), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if (user != nil) {
                self.updateCurrentUser(eMail: (Auth.auth().currentUser?.email)!)
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if (inputPass.text?.count ?? 0 >= 5) {
            let mail = inputMail.text
            let regex = try! NSRegularExpression(pattern: EMAIL_REGEX, options: [])
            let matches = regex.matches(in: mail ?? "", options: [], range: NSRange(location: 0, length: mail?.count ?? 0))

            if (matches.count == 1) {
                loginBtn.isEnabled = true
            } else {
                loginBtn.isEnabled = false
            }
        } else {
            loginBtn.isEnabled = false
        }
    }
    
    @objc func login(_ sender: AnyObject?) {
        loginBtn.isEnabled = false
        registerBtn.isEnabled = false
        
        Auth.auth().signIn(withEmail: inputMail.text!, password: inputPass.text!) {
            (user, err) in
            if (err != nil) {
                self.makeAlert(title: "Error!", message: "Sign in error")
                self.loginBtn.isEnabled = true
                self.registerBtn.isEnabled = true
            } else {
                self.updateCurrentUser(eMail: self.inputMail.text!)
            }
        }
    }
    
    func updateCurrentUser(eMail: String) {
        self.db.collection("userDetail").document(eMail).getDocument { (document, err) in
            if (err != nil) {
                self.makeAlert(title: "Error!", message: "Login Error")
            } else if let document = document, document.exists {
                let data = document.data()
                let user = User(JSON: data!)
                CurrentUser.shared.user = user!
                self.performSegue(withIdentifier: "toTabBar", sender: nil)
            }
        }
    }
    
    @objc func resetPass(_ sender: AnyObject?) {
        let popUp = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "popUpResetPass") as! PopUpResetPassVC
        self.addChild(popUp)
        popUp.view.frame = self.view.frame
        self.view.addSubview(popUp.view)
        popUp.didMove(toParent: self)
    }
    
    @objc func toggleSecure(_ sender: AnyObject?) {
        show = !show
        
        if (show) {
            inputPass.isSecureTextEntry = false
            toggleSecureBtn.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        } else {
            inputPass.isSecureTextEntry = true
            toggleSecureBtn.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        }
    }
    
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toHomeVC") {
            let destinationVC = segue.destination as! HomeViewController
            destinationVC.eMail = (Auth.auth().currentUser?.email)!
        }
    }
    */
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okBtn = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }
    
}
