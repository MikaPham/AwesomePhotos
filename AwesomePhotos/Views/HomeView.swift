//
//  HomeView.swift
//  AwesomePhotos
//
//  Created by Apple on 3/28/19.
//  Copyright © 2019 Minh Quang Pham. All rights reserved.
//

import UIKit
import SnapKit

class HomeView : GenericView {
    
    //MARK: - UI
    var welcomeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 28)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        return label
    }()
    
    //MARK: - Helper function
    override func configureView() {
        self.backgroundColor = UIColor.mainBlue()
        
        self.addSubview(welcomeLabel)
        welcomeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        welcomeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
}
