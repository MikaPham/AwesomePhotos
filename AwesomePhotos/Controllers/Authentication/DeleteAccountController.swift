//
//  ForgotPasswordController.swift
//  AwesomePhotos
//
//  Created by Apple on 4/27/19.
//  Copyright © 2019 Minh Quang Pham. All rights reserved.
//

import UIKit
import Firebase

//ForgotPasswordController for ForgotPasswordView
class DeleteAccountController : GenericViewController<DeleteAccountView> {
    
    let db = Firestore.firestore()
    
    //MARK: - UI
    func configureNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icons8-left"), style: .plain, target: self, action: #selector(handleGoBack))
        navigationItem.leftBarButtonItem?.tintColor = .black
        navigationController?.navigationBar.barTintColor = UIColor.lightGray()
        self.title = "Delete account"
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate; //To enable go back to previous screen with left swipe
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    
    //MARK: - Init
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        
        //To lock screen in portrait mode
        super.viewWillAppear(animated)
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.shouldSupportOrientation = .portrait // set desired orientation
        let value = UIInterfaceOrientation.portrait.rawValue // set desired orientation
        UIDevice.current.setValue(value, forKey: "orientation")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
    }
    
    //MARK: - Selectors
    @objc func handleGoBack(){
        navigationController?.navigationBar.isHidden = true
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleDeleteAccount(){
        deleteAccount()
    }
    
    //MARK: - API
    fileprivate func deleteFromAuth() {
        guard let user = Auth.auth().currentUser else { return }
        // Remove user from Auth
        user.delete { error in
            if let error = error {
                let alert = AlertService.basicAlert(imgName: "GrinFace", title: "Delete account failed", message: error.localizedDescription)
                self.present(alert, animated: true)
                return
            } else {
                print("Successfully delete user")
            }
        }
    }
    
    func deleteAccount() {
        deleteFromAuth()
        let alert = AlertService.alertNextScreen(imgName: "SmileFace",title: "Account deleted",message: "Your account has been deleted. We hope to see you again soon!", currentScreen: self, nextScreen: LoginController())
        self.present(alert,animated: true)
    }
}
