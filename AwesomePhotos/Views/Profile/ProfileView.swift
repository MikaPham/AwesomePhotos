//
//  ProfileViewController+NavBar.swift
//  ProfilePage
//
//  Created by Bob on 29/4/19.
//  Copyright © 2019 RMIT. All rights reserved.
//

import UIKit

class ProfileView: GenericView {
    
    // Create top red background for profile
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red:0.85, green:0.22, blue:0.17, alpha:1.0)
        
        // Add ProfileImageView into container + configure constraints
        view.addSubview(profileImageView)
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.anchor(top: view.topAnchor, paddingTop: 28, width: 120, height: 120)
        profileImageView.layer.cornerRadius = 120/2
        
        // Add EmailLabel into container + configure constraints
        view.addSubview(emailLabel)
        emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailLabel.anchor(top: profileImageView.bottomAnchor, paddingTop: 14)
        
        // Add Buttons into container + configure constraints
        view.addSubview(stackView)
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.anchor(top: emailLabel.bottomAnchor, paddingTop: 20)
    
        return view
    }()
    
    // Create UIImageView for profile and configure its attributes
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "SleepFace")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        iv.layer.borderWidth = 3
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.shadowColor = UIColor.black.cgColor
        iv.layer.shadowOpacity = 1
        iv.layer.shadowOffset = CGSize(width: 0, height: 1)
        iv.layer.shadowRadius = 4
        return iv
    }()
    
    // Create emailLabel
    let emailLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = .white
        return label
    }()
    
    // Create Button to display total Photos
    let totalPhotosButton: CustomTotalButton = {
        let button = CustomTotalButton(type: .system)
        
        // Add action to the button
        button.addTarget(self, action: #selector(ProfileViewController.showAllPhotos), for: .touchUpInside)
        return button
    }()
    
    // Create Button to display total Videos
    let totalVidesButton: CustomTotalButton = {
        let button = CustomTotalButton(type: .system)
    
        // Add action to the button
        button.addTarget(self, action: #selector(ProfileViewController.showAllVideos), for: .touchUpInside)
        
        return button
    }()
    
    // Create Button to display total Shared files
    let totalSharedButton: CustomTotalButton = {
        let button = CustomTotalButton(type: .system)
        
        // Add action to the button
        button.addTarget(self, action: #selector(ProfileViewController.showAllShared), for: .touchUpInside)
        
        return button
    }()
    
    // Create Button to display total Photos
    lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [totalPhotosButton, totalVidesButton, totalSharedButton])
        sv.axis = .horizontal
        sv.spacing = 28
        sv.distribution = .fillEqually
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    override func configureView() {
        self.backgroundColor = .white
        
        // Add container and it's elements into ProfileVC
        self.addSubview(containerView)
        containerView.anchor(top: self.safeAreaLayoutGuide.topAnchor, left: self.leftAnchor, right: self.rightAnchor, height: 300)
    }
}
