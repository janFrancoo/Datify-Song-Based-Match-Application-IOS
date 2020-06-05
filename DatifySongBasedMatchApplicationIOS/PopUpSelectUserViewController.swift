//
//  PopUpSelectUserViewController.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 4.06.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import UIKit
import Kingfisher

class PopUpSelectUserViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var users: [User]?
    var matchTrack: String!
    
    @IBOutlet weak var usersCollectionView: UICollectionView!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var matchTrackLabel: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertView.layer.cornerRadius = 16
        alertView.clipsToBounds = true
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        matchTrackLabel.text = "Matched on: \(matchTrack ?? "")"
        
        // let tap = UITapGestureRecognizer(target: self, action: #selector(self.removeAnimate(_:)))
        // self.view.addGestureRecognizer(tap)
        cancelBtn.addTarget(self, action: #selector(self.removeAnimate(_:)), for: .touchUpInside)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if users != nil {
            return users!.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userSelectCell", for: indexPath)
            as! UserSelectCollectionViewCell
        let user = users![indexPath.row]
        
        if user.avatarUrl != "default" {
            cell.avatarImageView.kf.setImage(with: URL(string: user.avatarUrl!)!)
        }
        cell.usernameLabel.text = user.username
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = users![indexPath.row]
        if let homeVC = self.storyboard!.instantiateViewController(withIdentifier: "homeVC") as? HomeViewController {
            let chatName = homeVC.generateChatName(user.eMail!)
            homeVC.createChat(chatName, user)
            present(homeVC, animated: true, completion: nil)
            self.removeAnimate(nil)
        }
    }
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    @objc func removeAnimate(_ sender: AnyObject?) {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 0.0
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }, completion: { (finished: Bool) in
            if finished {
                self.view.removeFromSuperview()
            }
        })
    }

}
