//
//  SignUpController.swift
//  AwesomePhotos
//
//  Created by Apple on 3/26/19.
//  Copyright © 2019 Minh Quang Pham. All rights reserved.
//

import UIKit
import Firebase

//SignUpController for SignUpView
class SignUpController: GenericViewController<SignUpView>, UITextFieldDelegate {
    
    let adminScope = "0"
    let userScope = "1"
    
    let db = Firestore.firestore()
  
    
    //MARK: UI
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //To lock screen in portrait mode
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.shouldSupportOrientation = .portrait // set desired orientation
        let value = UIInterfaceOrientation.portrait.rawValue // set desired orientation
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    
    //MARK: Init
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        hideKeyboardWhenTappedAround()
        //Delegate textfields to make keyboard disappear when tap Return on keyboard
        contentView.emailTextField.delegate = self
        contentView.passwordTextField.delegate = self
    }
    
    //Function to make keyboard disappear when tap Return on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        contentView.emailTextField.resignFirstResponder()
        contentView.passwordTextField.resignFirstResponder()
        return true
    }
    
    
    // MARK: - Selectors
    @objc func handleSignUp() {
        guard let email = contentView.emailTextField.text else { return }
        guard let password = contentView.passwordTextField.text else { return }
        
        createUser(withEmail: email, password: password)
    }
    
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func alertClose(gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - API
    func createUser(withEmail email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in //Attmept sign user up
            //If sign up fails
            if let error = error {
                let alert = UIAlertController(title: "Sign up failed", message: error.localizedDescription, preferredStyle: .alert)
                self.present(alert, animated: true, completion:{
                    alert.view.superview?.isUserInteractionEnabled = true
                    alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertClose)))
                })
                return
            }
            
            //If sign up succeeds update user account with their username
            guard let uid = result?.user.uid else { return }
            let values = ["email": email, "scope": self.userScope]
            
            self.db.collection("users").addDocument(data: values) { error in
                //If update username fails
                if let error = error {
                    let alert = UIAlertController(title: "Sign up failed", message: error.localizedDescription, preferredStyle: .alert)
                    self.present(alert, animated: true, completion:{
                        alert.view.superview?.isUserInteractionEnabled = true
                        alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertClose)))
                    })
                }
            }
            
            //If updates succeeds directs user to HomeController
            self.present(AlertService.alert(imgName: "SmileFace", title: "Sign up success", message: "We will direct you to your homescreen"), animated: true)
            
            guard let navController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController else { return }
            guard navController.viewControllers[0] is HomeController else { return }
            self.dismiss(animated: true, completion: nil)
        }
    }
}
