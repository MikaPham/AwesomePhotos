//
//  HomeController.swift
//  AwesomePhotos
//
//  Created by Apple on 3/26/19.
//  Copyright © 2019 Minh Quang Pham. All rights reserved.
//

import UIKit
import Firebase

class HomeController: GenericViewController<HomeView> {
    
    
    //MARK: - UI
    func configureNavBar() {
        navigationItem.title = "AwesomePhotos"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icons8-left"), style: .plain, target: self, action: #selector(handleSignOut))
        navigationItem.leftBarButtonItem?.tintColor = .black
        navigationController?.navigationBar.barTintColor = UIColor.lightGray()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.mainRed()]
    }
    
    
    //MARK: - Init
    override func viewWillAppear(_ animated: Bool) {
        authenticateUser()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
    }
    
    
    //MARK: - Selector
    @objc func handleSignOut() {
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { (_) in
            self.signOut()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func alertClose(gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: - API
    func loadUserData() {
        print("loading user data")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        print(uid)
        Database.database().reference().child("users").child(uid).child("email").observeSingleEvent(of: .value) { (snapshot) in
            guard let email = snapshot.value as? String else { return }
            self.contentView.welcomeLabel.text = "Welcome, \(email)"
            
            UIView.animate(withDuration: 0.5, animations: {
                self.contentView.welcomeLabel.alpha = 1
            })
        }
    }
    
    func authenticateUser() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let navController = UINavigationController(rootViewController: LoginController())
                navController.navigationBar.barStyle = .black
                self.present(navController, animated: true, completion: nil)
            }
        } else {
            loadUserData()
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            let navController = UINavigationController(rootViewController: LoginController())
            navController.navigationBar.barStyle = .black
            self.present(navController, animated: true, completion: nil)
        } catch let error as NSError{
            print("Failed to sign out with error", error)
            let alert = UIAlertController(title: "Sign out failed", message: "Failed to sign user out", preferredStyle: .alert)
            self.present(alert, animated: true, completion:{
                alert.view.superview?.isUserInteractionEnabled = true
                alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertClose)))
            })
        }
    }
    
}
