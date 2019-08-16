//
//  MeertsTableViewCell.swift
//  DrawPractice
//
//  Created by Will Fletcher on 8/6/19.
//  Copyright © 2019 Will Fletcher. All rights reserved.
//

import UIKit

class MeertsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var eventTypeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tintColor = #colorLiteral(red: 1, green: 0, blue: 0.496509254, alpha: 1)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
