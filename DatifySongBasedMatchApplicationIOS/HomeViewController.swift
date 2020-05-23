//
//  HomeViewController.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 18.05.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    var eMail = ""
    var user = CurrentUser.shared.user
    @IBOutlet weak var eMailLabel: UILabel!
    @IBOutlet weak var tmpSignOut: UIButton!
    @IBOutlet weak var tmpSettingsBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        eMailLabel.text = eMail
    
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        tmpSignOut.addTarget(self, action: #selector(HomeViewController.signOut(_:)), for: .touchUpInside)
        
        tmpSettingsBtn.addTarget(self, action: #selector(HomeViewController.goToSettings(_:)), for: .touchUpInside)
    }
    
    @objc func signOut(_ sender: AnyObject?) {
        try! Auth.auth().signOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func goToSettings(_ sender: AnyObject?) {
        self.performSegue(withIdentifier: "toSettingsVC", sender: nil )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toSettingsVC") {
            let destinationVC = segue.destination as! SettingsViewController
            destinationVC.backNav = true
        }
    }

}
