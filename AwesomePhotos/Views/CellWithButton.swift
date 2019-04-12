//
//  CellWithButton.swift
//  AwesomePhotos
//
//  Created by Apple on 4/12/19.
//  Copyright © 2019 Minh Quang Pham. All rights reserved.
//

import UIKit

class CellWithButton: UITableViewCell {
    @IBOutlet weak var shareButton: cellButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class cellButton : UIButton {
    
    var indexPath: IndexPath?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

