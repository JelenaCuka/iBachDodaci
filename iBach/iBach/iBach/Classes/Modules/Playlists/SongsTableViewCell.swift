//
//  SongsTableViewCell.swift
//  iBach
//
//  Created by Petar Jedek on 28.01.19.
//  Copyright © 2019 Petar Jedek. All rights reserved.
//

import UIKit

class SongsTableViewCell: CheckableTableViewCell {

    @IBOutlet var imageViewCoverArt: UIImageView!
    @IBOutlet var labelTrackTitle: UILabel!
    @IBOutlet var labelAuthor: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
