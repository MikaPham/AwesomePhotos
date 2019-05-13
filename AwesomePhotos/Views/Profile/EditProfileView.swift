//
//  EditProfileView.swift
//  AwesomePhotos
//
//  Created by User on 5/12/19.
//

import UIKit

class EditProfileView: GenericView {
    
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
        tf.textContentType = .newPassword
        tf.passwordRules = UITextInputPasswordRules(descriptor: "minlength: 6;")
        return tf.textField(withPlaceolder: "Password", isSecureTextEntry: true)
    }()
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "SleepFace")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        iv.layer.borderWidth = 3
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.shadowColor = UIColor.black.cgColor
        iv.layer.shadowOpacity = 1
        iv.layer.shadowOffset = CGSize(width: 0, height: 1)
        iv.layer.shadowRadius = 4
        return iv
    }()
    
    override func configureView() {
        self.backgroundColor = UIColor.white
        
//        self.addSubview(loginButton)
//        loginButton.snp.makeConstraints{(make) in
//            make.top.equalTo(self.snp.centerY).offset(50)
//            make.left.equalToSuperview().offset(120)
//            make.right.equalToSuperview().offset(-120)
//            make.height.equalTo(50)
//        }
        
        self.addSubview(profileImageView)
        profileImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        profileImageView.anchor(top: self.topAnchor, paddingTop: 28, width: 120, height: 120)
        profileImageView.layer.cornerRadius = 120/2
//        profileImageView.translatesAutoresizingMaskIntoConstraints = false
//        profileImageView.anchor(top: self.safeAreaLayoutGuide.topAnchor, left: self.leftAnchor, right: self.rightAnchor, height: 300)

        self.addSubview(emailContainerView)
        emailContainerView.snp.makeConstraints{(make) in
            make.top.equalTo(profileImageView.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.height.equalTo(50)
        }
        
        self.addSubview(passwordContainerView)
        passwordContainerView.snp.makeConstraints{(make) in
            make.top.equalTo(emailContainerView.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.height.equalTo(50)
        }
        
//        self.addSubview(logoImageView)
//        logoImageView.snp.makeConstraints{(make) in
//            make.bottom.equalTo(emailContainerView.snp_top).offset(-24)
//            make.width.equalTo(150)
//            make.height.equalTo(150)
//            make.centerX.equalToSuperview()
//        }
//
//        self.addSubview(dividerView)
//        dividerView.snp.makeConstraints{(make) in
//            make.top.equalTo(loginButton.snp_bottom).offset(60)
//            make.left.equalToSuperview().offset(32)
//            make.right.equalToSuperview().offset(-32)
//            make.height.equalTo(50)
//        }
//
//        self.addSubview(dontHaveAccountButton)
//        dontHaveAccountButton.snp_makeConstraints{(make) in
//            make.bottom.equalToSuperview().offset(-12)
//            make.left.equalToSuperview().offset(32)
//            make.right.equalToSuperview().offset(-32)
//            make.height.equalTo(50)
//        }
    }
}
