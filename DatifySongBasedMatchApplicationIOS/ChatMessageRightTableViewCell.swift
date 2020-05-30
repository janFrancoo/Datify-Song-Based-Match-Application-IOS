//
//  ChatMessageRightTableViewCell.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 30.05.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import UIKit

class ChatMessageRightTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tickImage: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var sentImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
