//
//  Alert.swift
//  AwesomePhotos
//
//  Created by Apple on 4/22/19.
//

import Foundation
import UIKit
import SnapKit

struct AlertService{
    
    static func alert(imgName: String, title: String, message: String) -> CustomAlertController {
        let storyboard = UIStoryboard(name: "CustomAlertController", bundle: .main)
        let alertVC = storyboard.instantiateViewController(withIdentifier: "AlertVC") as! CustomAlertController
        alertVC.imgName = imgName
        alertVC.titleContent = title
        alertVC.messageContent = message
        return alertVC
    }
}
