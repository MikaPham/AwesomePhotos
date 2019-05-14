//
//  EditProfileViewController.swift
//  AwesomePhotos
//
//  Created by User on 5/11/19.
//

import UIKit
import Firebase

class EditProfileViewController: GenericViewController<EditProfileView>, UITextFieldDelegate{
    
    var myEmail: String?
    var userNewEmail: String?
    var userNewPassword:String?
    var userOldPassword: String?
    var docRef: DocumentReference?
    lazy var currentUser = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadUserData()
        setupNavBar()
        
        // Load user
        contentView.emailTextField.delegate = self
        contentView.oldPasswordTextField.delegate = self
        contentView.newPasswordTextField.delegate = self
        }
    
    // Go back to previous screen (Profile)
    @objc func backHome(){
        self.dismiss(animated: true, completion: nil)
    }
    
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
   

    @objc func saveEdit(){
        view.endEditing(true)
        updateUser()
    }
    
    //fetch current useremail to email text field
    func loadUserData(){
        self.myEmail = currentUser?.email
        self.contentView.emailTextField.text = myEmail
    }
    
    //handles profile changes
    func updateUser(){
        
        guard let email = contentView.emailTextField.text else { return }
        guard let oldPassword = contentView.oldPasswordTextField.text else { return }
        guard let newPassword = contentView.newPasswordTextField.text else { return }

        //check authentication before making changes
        let credential = EmailAuthProvider.credential(withEmail: self.myEmail!, password: oldPassword)

        currentUser?.reauthenticate(with: credential, completion: { (AuthResultCallback, error) in
        
        //Alert user if succeeded or failed
            // If update fails
            if let error = error {
                let alert = AlertService.basicAlert(imgName: "GrinFace", title: "Changes could not be saved", message: "The email or password you entered is incorrect")
                self.present(alert, animated: true)
                return
            }
            //If updates succeeds
            self.currentUser?.updateEmail(to: email)
            self.currentUser?.updatePassword(to: newPassword)
            let alert = AlertService.basicAlert(imgName: "SmileFace", title: "Changes Saved", message: "Your account has been updated.")
            self.present(alert, animated: true)
        })
    }
    
    //Function to make keyboard disappear when tap Return on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        contentView.emailTextField.resignFirstResponder()
        contentView.newPasswordTextField.resignFirstResponder()
        contentView.oldPasswordTextField.resignFirstResponder()

        return true
    }
    
    
}
    


