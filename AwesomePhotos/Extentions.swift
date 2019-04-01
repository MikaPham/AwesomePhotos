//
//  Extentions.swift
//  AwesomePhotos
//
//  Created by Apple on 3/26/19.
//  Copyright © 2019 Minh Quang Pham. All rights reserved.
//

import UIKit
import SnapKit
import TextFieldEffects

//For textfields with images in logInVIew/ signUpView/ forgotPasswordView
extension UIView {
    func textContainerView(view: UIView, _ image: UIImage, _ textField: UITextField) -> UIView {
        view.backgroundColor = .clear
        
        let imageView = UIImageView()
        imageView.image = image

        view.addSubview(imageView)
        imageView.snp.makeConstraints{(make) in
            make.left.equalToSuperview().offset(8)
            make.centerY.equalToSuperview().offset(8)
            make.width.equalTo(25)
            make.height.equalTo(25)
        }
        
        view.addSubview(textField)
        textField.snp.makeConstraints{(make) in
            make.top.equalToSuperview()
            make.left.equalTo(imageView.snp_right).offset(12)
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
        }
        
        return view
    }
}

//Definition of all colors used in the app
extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static func mainBlue() -> UIColor {
        return UIColor.rgb(red: 0, green: 150, blue: 255)
    }
    
    static func mainGray() -> UIColor {
        return UIColor.rgb(red: 168, green: 168, blue: 168)
    }
    
    static func lightGrey() -> UIColor {
        return UIColor.rgb(red: 230, green: 230, blue: 230)
    }
    
    static func mainRed() -> UIColor {
        return UIColor.rgb(red: 218, green: 55, blue: 44)
    }
}

//For text fields in logInVIew/ signUpView/ forgotPasswordView
extension UITextField {
    func textField(withPlaceolder placeholder: String, isSecureTextEntry: Bool) -> UITextField {
        let tf = YoshikoTextField()
        tf.font = UIFont.systemFont(ofSize: 17)
        tf.textColor = .black
        tf.isSecureTextEntry = isSecureTextEntry
        tf.attributedPlaceholder = NSAttributedString(string: placeholder)
        tf.inactiveBorderColor = UIColor.lightGrey()
        tf.activeBorderColor = UIColor.mainRed()
        tf.autocapitalizationType = .none
        return tf
    }
}

//To hide keyboard when tapped on anywhere else on the screen
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
