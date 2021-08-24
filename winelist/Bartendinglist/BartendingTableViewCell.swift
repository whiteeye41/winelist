//
//  BartendingTableViewCell.swift
//  winelist
//
//  Created by cosima on 2020/5/31.
//  Copyright © 2020 cosima. All rights reserved.
//

import UIKit

class BartendingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var barTendingImage: UIImageView!
    
    @IBOutlet weak var barTendingWinName: UILabel!
    
    @IBOutlet weak var barTendingWinType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
