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
    
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: (button.titleLabel?.font.pointSize)!)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.mainRed()
        button.addTarget(self, action: #selector(EditProfileViewController.saveEdit), for: .touchUpInside)
        button.layer.cornerRadius = 14
        return button
    }()
    
    override func configureView() {
        self.backgroundColor = UIColor.white
        
        self.addSubview(profileImageView)
        profileImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        profileImageView.anchor(top: self.topAnchor, paddingTop: 28, width: 120, height: 120)
        profileImageView.layer.cornerRadius = 120/2
        
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
        
        self.addSubview(saveButton)
        saveButton.snp.makeConstraints{(make) in
            make.top.equalTo(passwordContainerView.snp.bottom).offset(48)
            make.left.equalToSuperview().offset(120)
            make.right.equalToSuperview().offset(-120)
            make.height.equalTo(50)
        }
        
    }
}
