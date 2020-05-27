//
//  BlockedUserTableViewCell.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 24.05.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import UIKit

class BlockedUserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
