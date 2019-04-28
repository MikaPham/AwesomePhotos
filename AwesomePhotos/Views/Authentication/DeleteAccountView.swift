//
//  DeleteAccountView.swift
//  AwesomePhotos
//
//  Created by Apple on 4/27/19.
//

import UIKit
import SnapKit

class DeleteAccountView : GenericView {
    
    // MARK: - UI
    let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(named: "DeadFace")
        return iv
    }()
    
    let label1: UILabel = {
        let label = UILabel()
        label.text = "Are you sure?"
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 19)
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    let label2: UILabel = {
        let label = UILabel()
        label.text = "If you delete your account, all contents you uploaded to your account storage will be removed."
        label.textColor = UIColor.mainGray()
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    let label3: UILabel = {
        let label = UILabel()
        label.text = "This cannot be undone."
        label.textColor = UIColor.mainGray()
        label.font = UIFont.systemFont(ofSize: 17)
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete my account", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: (button.titleLabel?.font.pointSize)!)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.mainRed()
        button.addTarget(self, action: #selector(DeleteAccountController.handleDeleteAccount), for: .touchUpInside)
        button.layer.cornerRadius = 14
        return button
    }()
    
    //MARK: Helper functions
    
    override func configureView() {
        self.backgroundColor = .white
        
        self.addSubview(loginButton)
        loginButton.snp.makeConstraints{(make) in
            make.bottom.equalTo(self.snp.bottom).offset(-60)
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.height.equalTo(50)
        }
        
        self.addSubview(label3)
        label3.snp.makeConstraints{(make) in
            make.bottom.equalTo(self.snp.centerY).offset(50)
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
        }
        
        self.addSubview(label2)
        label2.snp.makeConstraints{(make) in
            make.bottom.equalTo(label3.snp_top).offset(-2)
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
        }
        
        self.addSubview(label1)
        label1.snp.makeConstraints{(make) in
            make.bottom.equalTo(label2.snp_top).offset(-8)
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
        }
        
        self.addSubview(logoImageView)
        logoImageView.snp.makeConstraints{(make) in
            make.bottom.equalTo(label1.snp_top).offset(-32)
            make.width.equalTo(120)
            make.height.equalTo(120)
            make.centerX.equalToSuperview()
        }
    }
}


