//
//  SettingsViewController.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 19.05.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var backNav = false
    var user = CurrentUser.shared.user
    var pickerSelected: String = ""
    var pickerData: [String] = [String]()
    let db = Firestore.firestore()
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var bioTextField: UITextField!
    @IBOutlet weak var genderPickerView: UIPickerView!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var blockedUsersBtn: UIButton!
    @IBOutlet weak var issueBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !backNav {
            self.navigationItem.setHidesBackButton(true, animated: true)
        }

        genderPickerView.delegate = self
        genderPickerView.dataSource = self
        pickerData = ["Neutral", "Male", "Female"]
        
        if user.gender == "Male" {
            genderPickerView.selectRow(1, inComponent: 0, animated: true)
        } else if (user.gender == "Female") {
            genderPickerView.selectRow(2, inComponent: 0, animated: true)
        } else {
            genderPickerView.selectRow(0, inComponent: 0, animated: true)
        }
        
        bioTextField.text = user.bio
        
        if user.avatarUrl != "default" {
            let url = URL(string: user.avatarUrl!)
            avatarImageView.kf.setImage(with: url)
        }
        
        avatarImageView.contentMode = UIView.ContentMode.scaleAspectFill
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.masksToBounds = false
        avatarImageView.layer.borderColor = UIColor.black.cgColor
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        avatarImageView.clipsToBounds = true
            
        updateBtn.addTarget(self, action: #selector(SettingsViewController.update(_:)), for: .touchUpInside)
        blockedUsersBtn.addTarget(self, action: #selector(SettingsViewController.goToBlockedUsers(_:)), for: .touchUpInside)
        issueBtn.addTarget(self, action: #selector(SettingsViewController.showIssuePopUp(_:)), for: .touchUpInside)
        
        avatarImageView.isUserInteractionEnabled = true
        let gestRecognizer = UITapGestureRecognizer(target: self, action: #selector(choosePic))
        avatarImageView.addGestureRecognizer(gestRecognizer)
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @objc func choosePic() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        avatarImageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func update(_ sender: AnyObject?) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let mediaFolder = storageRef.child("avatars")
        
        if let data = avatarImageView.image?.jpegData(compressionQuality: 0.5) {
            let uuid = UUID().uuidString
            let imageRef = mediaFolder.child("\(uuid).jpg")
            imageRef.putData(data, metadata: nil) { (metadata, error) in
                if error != nil {
                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Avatar upload error")
                } else {
                    imageRef.downloadURL { (url, error) in
                        if error != nil {
                            self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Avatar url error")
                        } else {
                            let imageURL = url?.absoluteString
                            self.user.avatarUrl = imageURL
                            self.user.bio = self.bioTextField.text
                            self.user.gender = self.pickerSelected
                            self.db.collection("userDetail").document(self.user.eMail!).setData(self.user.toJSON()) { (err) in
                                if (err != nil) {
                                    self.makeAlert(title: "Error!", message: err?.localizedDescription ?? "User update error")
                                } else {
                                    self.makeAlert(title: "Successful", message: "Updated successfully!")
                                    self.performSegue(withIdentifier: "toHomeVC", sender: nil)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func goToBlockedUsers(_ sender: AnyObject?) {
        self.performSegue(withIdentifier: "toBlockedUsers", sender: nil)
    }
    
    @objc func showIssuePopUp(_ sender: AnyObject?) {
        let popUp = self.storyboard!.instantiateViewController(withIdentifier: "popUpSendIssue")
            as! PopUpIssueSendViewController
        self.addChild(popUp)
        popUp.view.frame = self.view.frame
        self.view.addSubview(popUp.view)
        popUp.didMove(toParent: self)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerSelected = pickerData[row]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toHomeVC" {
            _ = segue.destination as! HomeViewController
        } else if segue.identifier == "toBlockedUsers" {
            _ = segue.destination as! BlockedUsersViewController
        }
    }
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okBtn = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }

}
