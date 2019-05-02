//
//  LoginController.swift
//  AwesomePhotos
//
//  Created by Apple on 3/26/19.
//  Copyright © 2019 Minh Quang Pham. All rights reserved.
//

import UIKit
import Firebase

//LoginController for LogInView
class LoginController: GenericViewController<LogInView>, UITextFieldDelegate {
    
    
    //MARK: - Init
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
    
    
    //MARK: - Selectors
    @objc func handleLogin() {
        guard let email = contentView.emailTextField.text else { return }
        guard let password = contentView.passwordTextField.text else { return }
        logUserIn(withEmail: email, password: password)
    }
    
    @objc func handleShowSignUp() {
        navigationController?.pushViewController(SignUpController(), animated: true)
    }
    
    @objc func handleForgotPassword() {
        navigationController?.pushViewController(ForgotPasswordController(), animated: true)
    }
    
    
    //MARK: - API
    func logUserIn(withEmail email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) {(result,error) in //Attempt log user in
            //If log in fails
            if let error = error {
                let alert = AlertService.basicAlert(imgName: "GrinFace", title: "Log in failed", message: error.localizedDescription)
                self.present(alert, animated: true)
                return
            }
            DispatchQueue.main.async {
                let navController = UINavigationController(rootViewController: DeleteAccountController())
                navController.navigationBar.barStyle = .black
                self.present(navController, animated: true, completion: nil)
            }
        }
    }
}
