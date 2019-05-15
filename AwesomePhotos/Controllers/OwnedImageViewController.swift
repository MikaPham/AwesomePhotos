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
    var owned: Bool?
    var shared: Bool?
    var wm: Bool?
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
        if self.owned! {
            self.db.collection("photos").document(self.photoUid!).updateData(
                ["owners" : FieldValue.arrayRemove([self.userUid!])]
            )
        } else if self.shared! {
            self.db.collection("photos").document(self.photoUid!).updateData(
                ["sharedWith" : FieldValue.arrayRemove([self.userUid!])]
            )
        } else if self.wm! {
            self.db.collection("photos").document(self.photoUid!).updateData(
                ["sharedWM" : FieldValue.arrayRemove([self.userUid!])]
            )
        }
        self.handleGoBack()
    }
    
    fileprivate func getInfo() {
        let reference = Storage.storage()
            .reference(forURL: "gs://awesomephotos-b794e.appspot.com/")
            .child(self.filePath!)
        
        reference.getMetadata { metadata, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                let infoStoryboard: UIStoryboard = UIStoryboard(name: "Info", bundle: nil)
                let infoController: InfoController = infoStoryboard.instantiateViewController(withIdentifier: "InfoController") as! InfoController
                infoController.infoArray.append((metadata?.name)!)
                infoController.infoArray.append("\(metadata!.size) bytes")
                infoController.infoArray.append( self.convertRFC3339DateTimeToString(rfc3339DateTime: metadata?.timeCreated))
                infoController.infoArray.append((metadata?.md5Hash)!)
                infoController.infoArray.append(self.owned! ? "Yes" : "No")
                infoController.selectedImage = self.selectedImage.image
                self.navigationController?.pushViewController(infoController, animated: true)
            }
        }
    }
    
    @objc func showMoreActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let sharePhotoAction = UIAlertAction(title: "Share", style: .default) { action in
            self.showShareOptions()
        }
        let deleteAction = UIAlertAction(title: "Delete photo", style: .destructive) { action in
            let deleteAlert = UIAlertController(title: "Delete this photo?", message: "This will only delete this copy of the photo for you. It will still be visible for photo owners and shared users.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { action in
                self.deletePhoto()
            }
            deleteAlert.addAction(cancelAction)
            deleteAlert.addAction(deleteAction)
            self.present(deleteAlert, animated: true, completion: nil)
        }
        let infoAction = UIAlertAction(title: "Get info", style: .default) {[unowned self] action in
            self.getInfo()
        }
        let downloadAction = UIAlertAction(title: "Download", style: .default) {[unowned self] action in
            UIImageWriteToSavedPhotosAlbum(self.selectedImage.image!, self, nil, nil)
            self.present(AlertService.basicAlert(imgName: "SmileFace", title: "Download successful", message: "You can find a copy of this photo in your Photos Album."), animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title:"Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(cancel)
        if owned! {
            actionSheet.addAction(sharePhotoAction)
        }
        actionSheet.addAction(infoAction)
        actionSheet.addAction(downloadAction)
        actionSheet.addAction(deleteAction)
        present(actionSheet, animated: true, completion: nil)
    }
    
    fileprivate func convertRFC3339DateTimeToString(rfc3339DateTime: Date!) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        var userVisibleDateTimeString: String!
        let userVisibleDateFormatter = DateFormatter()
        userVisibleDateFormatter.dateStyle = DateFormatter.Style.medium
        userVisibleDateFormatter.timeStyle = DateFormatter.Style.short
        userVisibleDateTimeString = userVisibleDateFormatter.string(from: rfc3339DateTime!)
        
        return userVisibleDateTimeString
    }
    
    fileprivate func createDownloadLink() {
        let reference = Storage.storage()
            .reference(forURL: "gs://awesomephotos-b794e.appspot.com/")
            .child(self.filePath!)
        // Fetch the download URL
        reference.downloadURL { url, error in
            if let error = error {
                self.present(AlertService.basicAlert(imgName: "GrinFace", title: "Download Failed", message: error.localizedDescription), animated: true, completion: nil)
            } else {
                let downloadURL = url
                UIPasteboard.general.url = downloadURL
                self.present(AlertService.basicAlert(imgName: "SmileFace", title: "Link Copied", message: "The download link for the non-waterarked copy of this photo has been copied to your clipboard."), animated: true, completion: nil)
            }
        }
    }
    
    func showShareOptions() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let editPerAction = UIAlertAction(title: "Edit permission", style: .default) {[unowned self] action in
            let editStoryboard: UIStoryboard = UIStoryboard(name: "EditPermission", bundle: nil)
            let editPermissionController: EditPermissionController = editStoryboard.instantiateViewController(withIdentifier: "EditPermissionController") as! EditPermissionController
            editPermissionController.photoUid = self.photoUid!
            editPermissionController.isImage = true
            self.navigationController?.pushViewController(editPermissionController, animated: true)
        }
        let shareInAppAction = UIAlertAction(title: "Share in-app", style: .default) {[unowned self] action in
            let shareStoryboard: UIStoryboard = UIStoryboard(name: "Sharing", bundle: nil)
            let shareController: ShareController = shareStoryboard.instantiateViewController(withIdentifier: "ShareController") as! ShareController
            shareController.isImage = true
            shareController.photoUid = self.photoUid!
            shareController.filePath = self.filePath!
            self.navigationController?.pushViewController(shareController, animated: true)
        }
        let copyLinkAction = UIAlertAction(title: "Copy link", style: .default) {[unowned self] action in
            self.createDownloadLink()
        }
        let cancel = UIAlertAction(title:"Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(cancel)
        actionSheet.addAction(shareInAppAction)
        actionSheet.addAction(editPerAction)
        actionSheet.addAction(copyLinkAction)
        present(actionSheet, animated: true, completion: nil)
    }
}
