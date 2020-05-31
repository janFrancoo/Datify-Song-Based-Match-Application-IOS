//
//  TrackListTableViewCell.swift
//  DatifySongBasedMatchApplicationIOS
//
//  Created by JanFranco on 31.05.2020.
//  Copyright © 2020 janfranco. All rights reserved.
//

import UIKit

class TrackListTableViewCell: UITableViewCell {

    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var addDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
