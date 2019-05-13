//
//  EditProfileViewController.swift
//  AwesomePhotos
//
//  Created by User on 5/11/19.
//

import UIKit
import Firebase

class EditProfileViewController: GenericViewController<EditProfileView>, UITextFieldDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavBar()
        contentView.emailTextField.delegate = self
        
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
        
        // Add action to the button
        doneButton.addTarget(self, action: #selector(EditProfileViewController.moveToProfile), for: .touchUpInside)
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: doneButton)]
    }
    
    // Add action to settings button
    @objc func moveToProfile(){
        self.dismiss(animated: true, completion: nil)
    }
    
//    // Create UIImageView for profile and configure its attributes
//    let profileImageView: UIImageView = {
//        let iv = UIImageView()
//        iv.image = #imageLiteral(resourceName: "SleepFace")
//        iv.contentMode = .scaleAspectFill
//        iv.clipsToBounds = true
//        iv.layer.masksToBounds = true
//        iv.layer.borderWidth = 3
//        iv.layer.borderColor = UIColor.white.cgColor
//        iv.layer.shadowColor = UIColor.black.cgColor
//        iv.layer.shadowOpacity = 1
//        iv.layer.shadowOffset = CGSize(width: 0, height: 1)
//        iv.layer.shadowRadius = 4
//        return iv
//    }()
//    
//    // Create top red background for profile
//    lazy var containerView: UIView = {
//        let view = UIView()
////        view.backgroundColor = UIColor(red:0.85, green:0.22, blue:0.17, alpha:1.0)
//        
//        // Add ProfileImageView into container + configure constraints
//        view.addSubview(profileImageView)
//        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        profileImageView.anchor(top: view.topAnchor, paddingTop: 28, width: 120, height: 120)
//        profileImageView.layer.cornerRadius = 120/2
//        
//        return view
//    }()
//    
//    lazy var emailContainerView: UIView = {
//        let view = UIView()
//        return view.textContainerView(view: view, UIImage(named:"icons8-new_post")!, emailTextField)
//    }()
//    
//    lazy var passwordContainerView: UIView = {
//        let view = UIView()
//        return view.textContainerView(view: view, UIImage(named:"icons8-lock")!, passwordTextField)
//    }()
//    
//    lazy var emailTextField: UITextField = {
//        let tf = UITextField()
//        return tf.textField(withPlaceolder: "Email", isSecureTextEntry: false)
//    }()
//    
//    lazy var usernameTextField: UITextField = {
//        let tf = UITextField()
//        return tf.textField(withPlaceolder: "Username", isSecureTextEntry: false)
//    }()
//    
//    lazy var passwordTextField: UITextField = {
//        let tf = UITextField()
//        tf.textContentType = .newPassword
//        tf.passwordRules = UITextInputPasswordRules(descriptor: "minlength: 6;")
//        return tf.textField(withPlaceolder: "Password", isSecureTextEntry: true)
//    }()

}
