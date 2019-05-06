//
//  ProfileViewController.swift
//  ProfilePage
//
//  Created by Minh Kha Pham on 29/4/19.
//  Copyright © 2019 RMIT. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    
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
        
        view.addSubview(addProfile)
        addProfile.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        addProfile.anchor(left: profileImageView.rightAnchor, paddingLeft: 20, width: 50, height: 50)
        
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
        label.text = "TaylorSwiftFan9x@gmail.com"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = .white
        return label
    }()
    
    // Create Button to display total Photos
    let totalPhotosButton: CustomTotalButton = {
        let button = CustomTotalButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "100\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.black])
        attributedTitle.append(NSAttributedString(string: "Photos", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.gray]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        // Add action to the button
        button.addTarget(self, action: #selector(showAllPhotos), for: .touchUpInside)
        return button
    }()
    
    // Create Button to display total Videos
    let totalVidesButton: CustomTotalButton = {
        let button = CustomTotalButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "100\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.black])
        attributedTitle.append(NSAttributedString(string: "Videos", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.gray]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        // Add action to the button
        button.addTarget(self, action: #selector(showAllVideos), for: .touchUpInside)

        return button
    }()
    
    // Create Button to display total Shared files
    let totalSharedButton: CustomTotalButton = {
        let button = CustomTotalButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "100\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.black])
        attributedTitle.append(NSAttributedString(string: "Shared", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.gray]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        // Add action to the button
        button.addTarget(self, action: #selector(showAllShared), for: .touchUpInside)

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
    
    let addProfile: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("ADD Profile", for: .normal)
        button.addTarget(self, action: #selector(handleProfilePicture), for: .touchUpInside)
        return button
    }()

    // MARK: - LifeCycle

    // Create Button to display total Photos
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        view.backgroundColor = .white
        
        // Add container and it's elements into ProfileVC
         view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 300)
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
    
    // Function to choose new Profile Picture
    @objc func handleProfilePicture(){
        // Configure Image picker
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        // Present Image picker
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Selected image
        guard let selectedProfileImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        
        // Configure profileImageView with selected Image
        profileImageView.image = selectedProfileImage.withRenderingMode(.alwaysOriginal)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @objc func showAllPhotos(){
        print ("Move to all Photos")
    }
    @objc func showAllVideos(){
        print ("Move to all Videos")
    }
    @objc func showAllShared(){
        print ("Move to all Shared")
    }
}


