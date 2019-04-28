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
        iv.image = UIImage(named: "AwesomeLogo")
        return iv
    }()
    
    lazy var emailContainerView: UIView = {
        let view = UIView()
        return view.textContainerView(view: view, UIImage(named:"icons8-new_post")!, emailTextField)
    }()
    
    lazy var passwordContainerView: UIView = {
        let view = UIView()
        return view.textContainerView(view: view, UIImage(named:"icons8-lock")!, passwordTextField)
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
        button.setTitle("Sign up", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: (button.titleLabel?.font.pointSize)!)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.mainRed()
        button.addTarget(self, action: #selector(SignUpController.handleSignUp), for: .touchUpInside)
        button.layer.cornerRadius = 14
        return button
    }()
    
    lazy var dividerView: UIView = {
        let dividerView = UIView()
        
        let label = UILabel()
        label.text = "OR"
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 17)
        dividerView.addSubview(label)
        label.snp.makeConstraints{(make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        let separator1 = UIView()
        separator1.backgroundColor = UIColor.black
        dividerView.addSubview(separator1)
        separator1.snp.makeConstraints{(make) in
            make.left.equalTo(dividerView.snp_left).offset(8)
            make.right.equalTo(label.snp_left).offset(-8)
            make.height.equalTo(1.0)
            make.centerY.equalToSuperview()
        }

        let separator2 = UIView()
        separator2.backgroundColor = UIColor.black
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
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.black])
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.mainRed()]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(SignUpController.handleShowLogin), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Helper Functions
    
    override func configureView() {
        self.backgroundColor = UIColor.white
        
        self.addSubview(loginButton)
        loginButton.snp.makeConstraints{(make) in
            make.top.equalTo(self.snp.centerY).offset(50)
            make.left.equalToSuperview().offset(120)
            make.right.equalToSuperview().offset(-120)
            make.height.equalTo(50)
        }
        
        self.addSubview(passwordContainerView)
        passwordContainerView.snp.makeConstraints{(make) in
            make.bottom.equalTo(loginButton.snp_top).offset(-32)
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.height.equalTo(50)
        }
        
        self.addSubview(emailContainerView)
        emailContainerView.snp.makeConstraints{(make) in
            make.bottom.equalTo(passwordContainerView.snp_top).offset(-16)
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.height.equalTo(50)
        }
        
        self.addSubview(logoImageView)
        logoImageView.snp.makeConstraints{(make) in
            make.bottom.equalTo(emailContainerView.snp_top).offset(-24)
            make.width.equalTo(150)
            make.height.equalTo(150)
            make.centerX.equalToSuperview()
        }
        
        self.addSubview(dividerView)
        dividerView.snp.makeConstraints{(make) in
            make.top.equalTo(loginButton.snp_bottom).offset(60)
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
