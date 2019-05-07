//
//  ProfileViewController.swift
//  ProfilePage
//
//  Created by Minh Kha Pham on 29/4/19.
//  Copyright © 2019 RMIT. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: GenericViewController<ProfileView> {
    
    // MARK: - Properties
    
   
    // MARK: - LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //To lock screen in portrait mode
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.shouldSupportOrientation = .portrait // set desired orientation
        let value = UIInterfaceOrientation.portrait.rawValue // set desired orientation
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavBar()
        fetchCurrentUserData()

//        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    func setupNavBar(){
        
        // Set up navigation bar
        configureNavBar(title: "Profile")
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.largeTitleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.mainRed()]
//        navigationItem.title = "Profile"
        setupNavigationBarItems()
    }

    func setupNavigationBarItems(){
        
        // Configure and assign settingsButton into Nav bar
        let settingsButton = UIButton(type: .system)
        settingsButton.setImage(#imageLiteral(resourceName: "Settings").withRenderingMode(.alwaysOriginal), for: .normal)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.anchor(width: 28, height: 28)
        // Add action to the button
        settingsButton.addTarget(self, action: #selector(ProfileViewController.moveToSettings), for: .touchUpInside)
        
        let editProfileButton = UIButton(type: .system)
        editProfileButton.setImage(#imageLiteral(resourceName: "Edit").withRenderingMode(.alwaysOriginal), for: .normal)
        editProfileButton.anchor(width: 28, height: 28)
        
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: settingsButton),
                                              UIBarButtonItem(customView: editProfileButton)]
        
    }

    // Add action to settings button
    @objc func moveToSettings(){
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
//     Add action to settings button
//    @objc func moveToEditProfile(){
//        let editProfileVC = EditProfileViewController()
//        navigationController?.pushViewController(editProfileVC, animated: true)
//    }
    
    @objc func showAllPhotos(){
        print ("Move to all Photos")
    }
    @objc func showAllVideos(){
        print ("Move to all Videos")
    }
    @objc func showAllShared(){
        print ("Move to all Shared")
    }
    
    
    // MARK: - API
    // Fetch user data.
    func fetchCurrentUserData() {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
       
        Database.database().reference().child("users").child(currentUID).child("email").observeSingleEvent(of: .value) { (snapshot) in
            
            // Change emailLabel title.
            guard let userEmail = snapshot.value as? String else { return }
            self.contentView.emailLabel.text = userEmail
            
        }
        
    }
}

