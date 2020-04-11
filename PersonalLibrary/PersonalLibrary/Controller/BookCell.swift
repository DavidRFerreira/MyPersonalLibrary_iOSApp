//
//  BookCell.swift
//  PersonalLibrary
//
//  Created by macOSHighSierra on 02/04/2020.
//  Copyright © 2020 David R. Ferreira. All rights reserved.
//

import UIKit
import SwipeCellKit

class BookCell: SwipeTableViewCell
{
 
    @IBOutlet weak var labelBookTitle: UILabel!
    @IBOutlet weak var labelAuthorName: UILabel!
    @IBOutlet weak var labelImageCover: UIImageView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }

}
