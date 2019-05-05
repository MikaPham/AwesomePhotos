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
    
    static func lightGray() -> UIColor {
        return UIColor.rgb(red: 248, green: 248, blue: 248)
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
        tf.attributedPlaceholder = NSMutableAttributedString(string: placeholder)
        tf.placeholderFontScale = 0.8
        tf.inactiveBorderColor = UIColor.lightGray()
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
    
    func configureNavBar(title: String) {
        // Set up navigation bar color
        navigationController?.navigationBar.barTintColor = UIColor.lightGray()
        
        // Set up navigation bar back button
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleGoBack))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.mainRed()
        
        // Set up navigation bar title
        self.title = title
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.mainRed()]
        
        // To enable go back to previous screen with left swipe
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate;
    }
    
    @objc func handleGoBack(){
        navigationController?.popViewController(animated: true)
    }
}

// anchor() for quick constraint setup.
extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, paddingTop: CGFloat? = 0,
                paddingLeft: CGFloat? = 0, paddingBottom: CGFloat? = 0, paddingRight: CGFloat? = 0, width: CGFloat? = nil, height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop!).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft!).isActive = true
        }
        
        if let bottom = bottom {
            if let paddingBottom = paddingBottom {
                bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
            }
        }
        
        if let right = right {
            if let paddingRight = paddingRight {
                rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
            }
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}
