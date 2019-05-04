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
    
    
    // MARK: - API
    func createUser(withEmail email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) {(result, error) in //Attmept sign user up
            //If sign up fails
            if let error = error {
                let alert = AlertService.basicAlert(imgName: "GrinFace", title: "Sign up failed", message: error.localizedDescription)
                self.present(alert, animated: true)
                return
            }
            
            //If updates succeeds directs user to HomeController
            let customBtnStoryboard: UIStoryboard = UIStoryboard(name: "TabBar", bundle: nil)
            let customBtnController: CustomButton = customBtnStoryboard.instantiateViewController(withIdentifier: "CustomButton") as! CustomButton
            
            let alert = AlertService.alertNextScreen(imgName: "SmileFace",title: "Sign up success",message: "Welcome aboard! We will direct you to your homescreen", currentScreen: self, nextScreen: customBtnController)
            self.present(alert,animated: true)
        }
    }
}
