//
//  CustomAlertController.swift
//  AwesomePhotos
//
//  Created by Apple on 4/23/19.
//

import UIKit

class CustomAlertController : UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    var imgName = String()
    var titleContent = String()
    var messageContent = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgView.image = UIImage(named:imgName)
        titleLabel.text = titleContent
        messageLabel.text = messageContent
    }

    @IBAction func OKTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


class NextScreenAlertController : CustomAlertController {
    
    var nextScreen = UIViewController()
    var currentScreen = UIViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction override func OKTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            DispatchQueue.main.async {
                let navController = UINavigationController(rootViewController: self.nextScreen)
                self.currentScreen.present(navController, animated: true, completion: nil)
            }
        }
    }
}
