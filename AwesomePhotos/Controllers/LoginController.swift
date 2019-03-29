//
//  LoginController.swift
//  AwesomePhotos
//
//  Created by Apple on 3/26/19.
//  Copyright © 2019 Minh Quang Pham. All rights reserved.
//

import UIKit
import Firebase

class LoginController: GenericViewController<LogInView> {
    
    //MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        hideKeyboardWhenTappedAround()
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
    
    @objc func alertClose(gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - API
    
    func logUserIn(withEmail email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) {(result,error) in
            if let error = error {
                print("Failed to log in with error: ", error.localizedDescription)
                let alert = UIAlertController(title: "Log in failed", message: "Invalid email or password", preferredStyle: .alert)
                self.present(alert, animated: true, completion:{
                    alert.view.superview?.isUserInteractionEnabled = true
                    alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertClose)))
                })
                return
            }

            guard let navController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController else { return }
            guard navController.viewControllers[0] is HomeController else { return }
            self.dismiss(animated: true, completion: nil)
        }
    }
}
