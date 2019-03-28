//
//  Extentions.swift
//  AwesomePhotos
//
//  Created by Apple on 3/26/19.
//  Copyright © 2019 Minh Quang Pham. All rights reserved.
//

import UIKit
import SnapKit

extension UIView {
    func textContainerView(view: UIView, _ image: UIImage, _ textField: UITextField) -> UIView {
        view.backgroundColor = .clear
        
        let imageView = UIImageView()
        imageView.image = image
        imageView.alpha = 0.87
        view.addSubview(imageView)
        imageView.snp.makeConstraints{(make) in
            make.left.equalToSuperview().offset(8)
            make.width.equalTo(24)
            make.height.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        view.addSubview(textField)
        textField.snp.makeConstraints{(make) in
            make.left.equalTo(imageView.snp_right).offset(12)
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
        }
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(white: 1, alpha: 0.87)
        view.addSubview(separatorView)
        separatorView.snp.makeConstraints{(make) in
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.75)
        }
        
        return view
    }
}

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static func mainBlue() -> UIColor {
        return UIColor.rgb(red: 0, green: 150, blue: 255)
    }
}

extension UITextField {
    func textField(withPlaceolder placeholder: String, isSecureTextEntry: Bool) -> UITextField {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = .white
        tf.isSecureTextEntry = isSecureTextEntry
        tf.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        return tf
    }
}
