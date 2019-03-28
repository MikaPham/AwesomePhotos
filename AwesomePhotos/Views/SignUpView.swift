//
//  SignUpView.swift
//  AwesomePhotos
//
//  Created by Apple on 3/28/19.
//  Copyright © 2019 Minh Quang Pham. All rights reserved.
//

import UIKit
import SnapKit

class SignUpView : GenericView {
    
    // MARK: - UI
    
    let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(named: "firebase-logo")
        return iv
    }()
    
    lazy var emailContainerView: UIView = {
        let view = UIView()
        return view.textContainerView(view: view, UIImage(named:"ic_mail_outline_white_2x")!, emailTextField)
    }()
    
    lazy var usernameContainerView: UIView = {
        let view = UIView()
        return view.textContainerView(view: view, UIImage(named:"ic_person_outline_white_2x")!, usernameTextField)
    }()
    
    lazy var passwordContainerView: UIView = {
        let view = UIView()
        return view.textContainerView(view: view, UIImage(named:"ic_lock_outline_white_2x")!, passwordTextField)
    }()
    
    lazy var emailTextField: UITextField = {
        let tf = UITextField()
        return tf.textField(withPlaceolder: "Email", isSecureTextEntry: false)
    }()
    
    lazy var usernameTextField: UITextField = {
        let tf = UITextField()
        return tf.textField(withPlaceolder: "Username", isSecureTextEntry: false)
    }()
    
    lazy var passwordTextField: UITextField = {
        let tf = UITextField()
        return tf.textField(withPlaceolder: "Password", isSecureTextEntry: true)
    }()
    
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SIGN UP", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitleColor(UIColor.mainBlue(), for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(SignUpController.handleSignUp), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    
    lazy var dividerView: UIView = {
        let dividerView = UIView()
        
        let label = UILabel()
        label.text = "OR"
        label.textColor = UIColor(white: 1, alpha: 0.88)
        label.font = UIFont.systemFont(ofSize: 14)
        dividerView.addSubview(label)
        label.snp.makeConstraints{(make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        let separator1 = UIView()
        separator1.backgroundColor = UIColor(white: 1, alpha: 0.88)
        dividerView.addSubview(separator1)
        separator1.snp.makeConstraints{(make) in
            make.left.equalTo(dividerView.snp_left).offset(8)
            make.right.equalTo(label.snp_left).offset(-8)
            make.height.equalTo(1.0)
            make.centerY.equalToSuperview()
        }

        let separator2 = UIView()
        separator2.backgroundColor = UIColor(white: 1, alpha: 0.88)
        dividerView.addSubview(separator2)
        separator2.snp.makeConstraints{(make) in
            make.left.equalTo(label.snp_right).offset(8)
            make.right.equalTo(dividerView.snp_right).offset(-8)
            make.height.equalTo(1.0)
            make.centerY.equalToSuperview()
        }
        
        return dividerView
    }()
    
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white])
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(SignUpController.handleShowLogin), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Helper Functions
    
    override func configureView() {
        self.backgroundColor = UIColor.mainBlue()
        
        self.addSubview(logoImageView)
        logoImageView.snp.makeConstraints{(make) in
            make.top.equalToSuperview().offset(60)
            make.width.equalTo(150)
            make.height.equalTo(150)
            make.centerX.equalToSuperview()
        }
        
        self.addSubview(emailContainerView)
        emailContainerView.snp.makeConstraints{(make) in
            make.top.equalTo(logoImageView.snp_bottom).offset(24)
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.height.equalTo(50)
        }

        self.addSubview(usernameContainerView)
        usernameContainerView.snp.makeConstraints{(make) in
            make.top.equalTo(emailContainerView.snp_bottom).offset(16)
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.height.equalTo(50)
        }
        
        self.addSubview(passwordContainerView)
        passwordContainerView.snp.makeConstraints{(make) in
            make.top.equalTo(usernameContainerView.snp_bottom).offset(16)
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.height.equalTo(50)
        }
        
        self.addSubview(loginButton)
        loginButton.snp.makeConstraints{(make) in
            make.top.equalTo(passwordContainerView.snp_bottom).offset(24)
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.height.equalTo(50)
        }
        
        self.addSubview(dividerView)
        dividerView.snp.makeConstraints{(make) in
            make.top.equalTo(loginButton.snp_bottom).offset(24)
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.height.equalTo(50)
        }
        
        self.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.snp_makeConstraints{(make) in
            make.bottom.equalToSuperview().offset(-12)
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.height.equalTo(50)
        }
    }
}
