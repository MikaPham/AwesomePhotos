//
//  EditProfileViewController.swift
//  AwesomePhotos
//
//  Created by User on 5/11/19.
//

import UIKit
import Firebase

class EditProfileViewController: GenericViewController<EditProfileView>, UITextFieldDelegate{
    
    var user: User?
    var userNewEmail: String?
    var userNewPassword:String?
    
    var emailChanged = false
    var passwordChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
//        loadUserData()
        setupNavBar()
        contentView.emailTextField.delegate = self
        
        self.contentView.emailTextField.text = "user?.email"
        
//        view.addSubview(containerView)
//        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 300)
        }


//        fetchCurrentUserData()
    
    
    func setupNavBar(){
        // Set up navigation bar
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.mainRed()]
        navigationItem.title = "Edit Profile"
        setupNavigationBarItems()
    }
    
    func setupNavigationBarItems(){
        // Configure and assign settingsButton into Nav bar
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.tintColor = .mainRed()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backHome))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.mainRed()
    }
    
    // Add action to settings button
    @objc func moveToProfile(){
        self.dismiss(animated: true, completion: nil)
    }
    
    // Go back to previous screen (Profile)
    @objc func backHome(){
        self.dismiss(animated: true, completion: nil)
    }

    @objc func saveEdit(){
        view.endEditing(true)
        
        if emailChanged {
            updateEmail()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadUserData(){
        guard let user = self.user else {return}
        
        self.contentView.emailTextField.text = "useremail"
        self.contentView.passwordTextField.text = "password"
        
    }
    
    func updateEmail(){
        guard let userNewEmail = self.userNewEmail else {return}
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        guard emailChanged == true else {return}
        print(userNewEmail)
        Firestore.firestore().collection("users").document(currentUid).updateData(["email": userNewEmail])
        let profileVC = ProfileViewController()
        profileVC.fetchCurrentUserData()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func endEditing(_ textField: UITextField) {
        let trimmedString = contentView.emailTextField.text?.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
        
        guard user?.email != trimmedString else {
            emailChanged = false
            return
            //add alert service
        }
        
        guard trimmedString != "" else {
            emailChanged = false
            return
            //add alert service
        }
        
        self.userNewEmail = trimmedString?.lowercased()
        emailChanged = true
    }
}
