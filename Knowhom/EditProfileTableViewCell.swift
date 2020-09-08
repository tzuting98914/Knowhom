//
//  EditProfileTableViewCell.swift
//  Knowhom
//
//  Created by MIS@NSYSU on 2020/8/28.
//  Copyright © 2020年 knowhom. All rights reserved.
//

import UIKit

class EditProfileTableViewCell: UITableViewCell {
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var nameField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
