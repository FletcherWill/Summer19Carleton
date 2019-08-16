//
//  MeertsCell.swift
//  ChamberMate
//
//  Created by Will Fletcher on 8/13/19.
//  Copyright © 2019 Will Fletcher. All rights reserved.
//

import UIKit

class MeertsCell: UITableViewCell {

    @IBOutlet weak var InLabel: UILabel!
    @IBOutlet weak var outLabel: UILabel!
    @IBOutlet weak var mountLabel: UILabel!
    @IBOutlet weak var mountLQLabel: UILabel!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var introLQLabel: UILabel!
    @IBOutlet weak var ejacLabel: UILabel!
    @IBOutlet weak var ejacLQLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
