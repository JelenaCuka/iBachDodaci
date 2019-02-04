//
//  PlaylistsTableViewCell.swift
//  iBach
//
//  Created by Petar Jedek on 07.12.18.
//  Copyright © 2018 Petar Jedek. All rights reserved.
//

import UIKit

class PlaylistsTableViewCell: UITableViewCell {

    @IBOutlet var imageViewCoverArt: UIImageView!
    @IBOutlet var labelName: UILabel!
    @IBOutlet weak var imageViewLogo: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
