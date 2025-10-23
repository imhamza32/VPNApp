//
//  PremiumCell.swift
//  VPNApp
//
//  Created by Munib Hamza on 13/04/2023.
//

import UIKit

class PremiumCell: UITableViewCell {

    @IBOutlet weak var containerVU: UIView!
    @IBOutlet weak var checkImgVu: UIImageView!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        containerVU.borderWidth = selected ? 3 : 0
        // Configure the view for the selected state
    }
    
}
