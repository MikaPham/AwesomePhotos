//
//  ProfileViewController+NavBar.swift
//  ProfilePage
//
//  Created by Bob on 29/4/19.
//  Copyright © 2019 RMIT. All rights reserved.
//

import UIKit

extension ProfileViewController {
    
    func setupNavBar(){
        
        // Set up navigation bar
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.0)
        navigationController?.navigationBar.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor(red:0.85, green:0.22, blue:0.17, alpha:1.0)]
        navigationController?.navigationBar.largeTitleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor(red:0.85, green:0.22, blue:0.17, alpha:1.0)]
        navigationItem.title = "Profile"
        setupNavigationBarItems()
        
    }
    
    func setupNavigationBarItems(){
        
        // Configure and assign settingsButton into Nav bar
        let settingsButton = UIButton(type: .system)
        settingsButton.setImage(#imageLiteral(resourceName: "Settings").withRenderingMode(.alwaysOriginal), for: .normal)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.anchor(width: 28, height: 28)
        // Add action to the button
        settingsButton.addTarget(self, action: #selector(moveToSettings), for: .touchUpInside)
        
        let editProfileButton = UIButton(type: .system)
        editProfileButton.setImage(#imageLiteral(resourceName: "Edit").withRenderingMode(.alwaysOriginal), for: .normal)
        editProfileButton.anchor(width: 28, height: 28)

        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: settingsButton),
                                              UIBarButtonItem(customView: editProfileButton)]
        
    }
}
