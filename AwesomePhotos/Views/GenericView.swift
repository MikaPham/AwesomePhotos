//
//  GenericView.swift
//  AwesomePhotos
//
//  Created by Apple on 3/28/19.
//  Copyright © 2019 Minh Quang Pham. All rights reserved.
//

import UIKit

//A generic view from which all other views are going to inherit

public class GenericView : UIView {
    
    public required init() {
        super.init(frame: CGRect.zero)
        configureView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    internal func configureView(){}
    
}
