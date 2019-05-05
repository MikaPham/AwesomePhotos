//
//  CustomTotalButtons.swift
//  ProfilePage
//
//  Created by Bob on 30/4/19.
//  Copyright © 2019 RMIT. All rights reserved.
//

import UIKit

class CustomTotalButton: UIButton{
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setupCustomTotalButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCustomTotalButton(){
        setStyle()
        setShadow()
        anchor( width: 95, height: 60)
    }
    
    private func setStyle(){
        titleLabel!.lineBreakMode = .byWordWrapping
        titleLabel!.numberOfLines = 2
        titleLabel!.textAlignment = .center
        setTitleColor(.gray, for: .normal)
        backgroundColor = .white
        layer.cornerRadius = 14
    }
    
    private func setShadow(){
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 1
    }
}

