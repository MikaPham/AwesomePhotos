//
//  CustomButton.swift
//  Bottom nav bar
//
//  Created by User on 4/25/19.
//  Copyright © 2019 User. All rights reserved.
//

import UIKit
import SnapKit

class CustomButton: UITabBarController{
    
    override func viewDidLoad() { // Called when tab bar loads
        super.viewDidLoad()
        self.setupMiddleButton() // Sets up button
    }
    
    func setupMiddleButton() {
        
        let menuButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        
        var menuButtonFrame = menuButton.frame
        menuButtonFrame.origin.y = self.view.bounds.height - menuButtonFrame.height
        menuButtonFrame.origin.x = self.view.bounds.width/2 - menuButtonFrame.size.width/2
        
        menuButton.frame = menuButtonFrame
        
        menuButton.backgroundColor = UIColor.white
        menuButton.layer.cornerRadius = menuButtonFrame.height/2
        menuButton.setImage(UIImage(named: "Camera button"), for: .normal) // 450 x 450px
        menuButton.contentMode = .scaleAspectFit
        menuButton.addTarget(self, action: #selector(menuButtonAction), for: UIControl.Event.touchUpInside)
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(menuButton)
        menuButton.snp.makeConstraints{(make) in
            make.centerX.equalTo(tabBar.snp.centerX)
            make.bottom.equalTo(tabBar.snp.top).offset(37)
        }
    }
    
    @objc func menuButtonAction(sender: UIButton) {
        self.selectedIndex = 2
    }
}
