//
//  TabBarController.swift
//  AwesomePhotos
//
//  Created by User on 5/3/19.
//

import UIKit
import Firebase
import FirebaseUI

class TabBarController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var libraryCollectionView: UICollectionView!
    @IBOutlet weak var mySegmentedControl: UISegmentedControl!
    
    lazy var db = Firestore.firestore()
    lazy var userUid = Auth.auth().currentUser?.uid
    var photosUid: [String] = []
    var videosUid: [String] = []
    var ownedPhotosUid: [String] = []
    var nwmPhotosUid: [String] = []
    var wmPhotosUid: [String] = []
    var showPhotos = true
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:#selector(handleRefresh),for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.mainRed()
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.libraryCollectionView.addSubview(self.refreshControl)
        fetchPhotos()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if showPhotos {
            return photosUid.count
        } else {
            return videosUid.count
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! LibraryCollectionViewCell
        // Show photos
        if showPhotos {
            let photoUid = photosUid[indexPath.row]
            cell.myImage.image = nil
            DispatchQueue.global().async {
                self.db.collection("photos").document(photoUid).getDocument{document, error in
                    if let document = document, document.exists {
                        guard let data = document.data() else { return }
                        var photoType: String
                        if self.ownedPhotosUid.contains(photoUid) {
                            photoType = "pathToOG"
                        } else if self.nwmPhotosUid.contains(photoUid) {
                            photoType = "pathToNWM"
                        } else {
                            photoType = "pathToWM"
                        }
                        let reference = Storage.storage()
                            .reference(forURL: "gs://awesomephotos-b794e.appspot.com/")
                            .child(data[photoType] as! String)
                        cell.filePath = data[photoType] as? String
                        cell.photoUid = photoUid
                        DispatchQueue.main.async {
                            cell.myImage.sd_setImage(with: reference, placeholderImage: UIImage(named: "SleepFace"))
                        }
                    } else {
                        print("Document does not exist")
                        return
                    }
                }
            }
        // Show Videos
        } else {
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Instatiate the image view
        let ownedImageViewStoryboard: UIStoryboard = UIStoryboard(name: "OwnedImageView", bundle: nil)
        let ownedImageViewController: OwnedImageViewController = ownedImageViewStoryboard.instantiateViewController(withIdentifier: "ownedImageViewController") as! OwnedImageViewController
        let selectedCell = libraryCollectionView.cellForItem(at: indexPath) as! LibraryCollectionViewCell
        // Pass properties
        ownedImageViewController.filePath = selectedCell.filePath
        ownedImageViewController.photoUid = selectedCell.photoUid
        ownedImageViewController.owned = ownedPhotosUid.contains(selectedCell.photoUid!)
        ownedImageViewController.shared = nwmPhotosUid.contains(selectedCell.photoUid!)
        ownedImageViewController.wm = wmPhotosUid.contains(selectedCell.photoUid!)
        // Move to image view
        let navController = UINavigationController(rootViewController: ownedImageViewController)
        self.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func switchCustom(_ sender: UISegmentedControl) {
        showPhotos = !showPhotos
        libraryCollectionView.reloadData()
    }
    
    @IBOutlet var filterChoices: [UIButton]!
    
    @IBAction func filterAction(_ sender: UIButton) {
        filterChoices.forEach { (button) in
        button.isHidden = !button.isHidden }
    }
    
    
    @IBAction func filterChoicesTapped(_ sender: UIButton) {
    }
    
    fileprivate func clearArrays() {
        self.ownedPhotosUid.removeAll()
        self.nwmPhotosUid.removeAll()
        self.wmPhotosUid.removeAll()
        self.photosUid.removeAll()
    }
    
    func fetchPhotos() {
        self.db.collection("users").document(userUid!).addSnapshotListener{snapshot, error in
            self.clearArrays()
            if let document = snapshot, document.exists {
                guard let data = document.data() else { return }
                self.ownedPhotosUid = data["ownedPhotos"] as! [String]
                self.nwmPhotosUid = data["sharedPhotos"] as! [String]
                self.wmPhotosUid = data["wmPhotos"] as! [String]
                self.photosUid += data["ownedPhotos"] as! [String]
                self.photosUid += data["sharedPhotos"] as! [String]
                self.photosUid += data["wmPhotos"] as! [String]
            } else {
                print("Document does not exist")
                return
            }
        }
        DispatchQueue.main.async {
            self.libraryCollectionView.reloadData() // breakpoint here to see if storyNames still empty
        }
    }
    
    // Refresh control
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.libraryCollectionView.reloadData()
        refreshControl.endRefreshing()
    }
}


