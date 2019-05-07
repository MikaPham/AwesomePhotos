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
    
    
    //MARK: - API
    func loadUserData() {
        print("loading user data")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        print(uid)
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
    
}
