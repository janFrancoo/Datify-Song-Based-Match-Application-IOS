//
//  TabBarController.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 26.05.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
}
