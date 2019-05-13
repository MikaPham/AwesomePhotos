//
//  OwnedImageViewController.swift
//  AwesomePhotos
//
//  Created by Apple on 5/13/19.
//

import UIKit
import FirebaseUI

class OwnedImageViewController: UIViewController {
    
    var photoUid: String?
    var filePath: String?
    @IBOutlet weak var selectedImage: UIImageView!
    
    fileprivate func loadImage() {
        let reference = Storage.storage()
            .reference(forURL: "gs://awesomephotos-b794e.appspot.com/")
            .child(filePath!)
        selectedImage.sd_setImage(with: reference)
    }
    
    fileprivate func configureNavBar() {
        configureNavBar(title: "")
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "More", style: .plain, target: self, action: #selector(showMoreActionSheet))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.mainRed()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        loadImage()
    }
    
    override func handleGoBack() {
        DispatchQueue.main.async {
            let customBtnStoryboard: UIStoryboard = UIStoryboard(name: "TabBar", bundle: nil)
            let customBtnController: CustomButton = customBtnStoryboard.instantiateViewController(withIdentifier: "CustomButton") as! CustomButton
            let navController = UINavigationController(rootViewController: customBtnController)
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    @objc func showMoreActionSheet() {
        print("Will show action sheet here")
    }
}
