//
//  COPTableViewCell.swift
//  ChamberMate
//
//  Created by Will Fletcher on 8/14/19.
//  Copyright © 2019 Will Fletcher. All rights reserved.
//

import UIKit

class COPTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
