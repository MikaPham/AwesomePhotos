//
//  OwnedImageViewController.swift
//  AwesomePhotos
//
//  Created by Apple on 5/13/19.
//

import UIKit
import FirebaseUI
import Firebase

class OwnedImageViewController: UIViewController {
    
    var photoUid: String?
    var filePath: String?
    @IBOutlet weak var selectedImage: UIImageView!
    lazy var db = Firestore.firestore()
    var userUid = Auth.auth().currentUser?.uid
    
    fileprivate func loadImage() {
        let reference = Storage.storage()
            .reference(forURL: "gs://awesomephotos-b794e.appspot.com/")
            .child(filePath!)
        selectedImage.sd_setImage(with: reference)
    }
    
    fileprivate func configureNavBar() {
        configureNavBar(title: "")
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showMoreActionSheet))
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

    
    fileprivate func deletePhoto() {
        self.db.collection("users").document(self.userUid!).updateData(
            ["ownedPhotos" : FieldValue.arrayRemove([self.photoUid!])]
        )
        self.db.collection("photos").document(self.photoUid!).updateData(
            ["owners" : FieldValue.arrayRemove([self.userUid!])]
        )
        self.handleGoBack()
    }
    
    @objc func showMoreActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let sharePhotoAction = UIAlertAction(title: "Share", style: .default) { action in
            self.showShareOptions()
        }
        let editPerAction = UIAlertAction(title: "Edit permission", style: .default) { action in
            let editStoryboard: UIStoryboard = UIStoryboard(name: "EditPermission", bundle: nil)
            let editPermissionController: EditPermissionController = editStoryboard.instantiateViewController(withIdentifier: "EditPermissionController") as! EditPermissionController
            editPermissionController.photoUid = self.photoUid!
            self.navigationController?.pushViewController(editPermissionController, animated: true)
        }
        let deleteAction = UIAlertAction(title: "Delete photo", style: .destructive) { action in
            let deleteAlert = UIAlertController(title: "Delete this photo?", message: "This will only delete this copy of the photo for you. It will still be visible for other owners and shared users.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { action in
                self.deletePhoto()
            }
            deleteAlert.addAction(cancelAction)
            deleteAlert.addAction(deleteAction)
            self.present(deleteAlert, animated: true, completion: nil)
        }
        let infoAction = UIAlertAction(title: "Get info", style: .default) { action in
            print("Get info")
        }
        let cancel = UIAlertAction(title:"Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(cancel)
        actionSheet.addAction(sharePhotoAction)
        actionSheet.addAction(editPerAction)
        actionSheet.addAction(infoAction)
        actionSheet.addAction(deleteAction)
        present(actionSheet, animated: true, completion: nil)
    }
    
    func showShareOptions() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let shareInAppAction = UIAlertAction(title: "Share in-app", style: .default) { action in
            let shareStoryboard: UIStoryboard = UIStoryboard(name: "Sharing", bundle: nil)
            let shareController: ShareController = shareStoryboard.instantiateViewController(withIdentifier: "ShareController") as! ShareController
            shareController.photoUid = self.photoUid!
            shareController.filePath = self.filePath!
            self.navigationController?.pushViewController(shareController, animated: true)
        }
        let copyLinkAction = UIAlertAction(title: "Copy link", style: .default) { action in
            print("Copy link")
        }
        let cancel = UIAlertAction(title:"Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(cancel)
        actionSheet.addAction(shareInAppAction)
        actionSheet.addAction(copyLinkAction)
        present(actionSheet, animated: true, completion: nil)
    }
}
