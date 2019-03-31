//
//  ForgotPasswordView.swift
//  AwesomePhotos
//
//  Created by Apple on 3/31/19.
//  Copyright © 2019 Minh Quang Pham. All rights reserved.
//

import UIKit
import SnapKit

class ForgotPasswordView : GenericView {
    
    //MARK: - UI
    
    let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(named: "a-2")
        return iv
    }()
    
    let label1: UILabel = {
        let label = UILabel()
        label.text = "Enter the email address\n associated with you account"
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 19)
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    let label2: UILabel = {
        let label = UILabel()
        label.text = "We will email you a link to reset\n your password"
        label.textColor = UIColor.mainGray()
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    lazy var emailContainerView: UIView = {
        let view = UIView()
        return view.textContainerView(view: view, UIImage(named:"icons8-message-black")!, emailTextField)
    }()
    
    lazy var emailTextField: UITextField = {
        let tf = UITextField()
        return tf.textField(withPlaceolder: "Email", isSecureTextEntry: false)
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SEND", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.mainRed()
        button.addTarget(self, action: #selector(ForgotPasswordController.handleForgotPassword), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    
    //MARK: Helper functions
    
    override func configureView() {
        self.backgroundColor = .white
        
        self.addSubview(logoImageView)
        logoImageView.snp.makeConstraints{(make) in
            make.top.equalToSuperview().offset(150)
            make.width.equalTo(120)
            make.height.equalTo(120)
            make.centerX.equalToSuperview()
        }
        
        self.addSubview(label1)
        label1.snp.makeConstraints { (make) in
            make.top.equalTo(logoImageView.snp_bottom).offset(32)
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
        }
        
        self.addSubview(label2)
        label2.snp.makeConstraints { (make) in
            make.top.equalTo(label1.snp_bottom).offset(32)
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
        }
        
        self.addSubview(emailContainerView)
        emailContainerView.snp.makeConstraints{(make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(label2.snp_bottom).offset(32)
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.height.equalTo(50)
        }
        
        self.addSubview(loginButton)
        loginButton.snp.makeConstraints{(make) in
            make.top.equalTo(emailContainerView.snp_bottom).offset(32)
            make.left.equalToSuperview().offset(120)
            make.right.equalToSuperview().offset(-120)
            make.height.equalTo(50)
        }
    }
}
