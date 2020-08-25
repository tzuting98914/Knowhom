//
//  AddressDetailTableViewCell.swift
//  Project
//
//  Created by MIS@NSYSU on 2020/7/18.
//  Copyright © 2020年 huihuiteam. All rights reserved.
//

import UIKit

class AddressDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var value: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
