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
    var ownedPhotosUid: [String] = []
    var ownedVideoUid: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPhotos()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ownedPhotosUid.count + ownedVideoUid.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! LibraryCollectionViewCell
        let photoUid = ownedPhotosUid[indexPath.row]
        
        self.db.collection("photos").document(photoUid).getDocument{document, error in
            if let document = document, document.exists {
                guard let data = document.data() else { return }
                let reference = Storage.storage()
                    .reference(forURL: "gs://awesomephotos-b794e.appspot.com/")
                    .child(data["pathToOG"] as! String)
                cell.myImage.sd_setImage(with: reference, placeholderImage: UIImage(named: "AwesomeLogo"))
            } else {
                print("Document does not exist")
                return
            }
        }
        
        return cell
    }
    
    
    //        let cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentCell", for: indexPath) as! RecentCollectionViewCell
    //        cell1.myRecentImage.image = UIImage(named: dataArray[p][indexPath.row])
    //        return cell1
    
    
    //    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    //        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentCell", for: indexPath) as! RecentCollectionViewCell
    //        cell.myRecentImage.image = UIImage(named: dataArray[p][indexPath.row])
    //        return cell
    //    }
    
    
    @IBAction func switchCustom(_ sender: UISegmentedControl) {
        libraryCollectionView.reloadData()
    }
    
    @IBOutlet var filterChoices: [UIButton]!
    
    @IBAction func filterAction(_ sender: UIButton) {
        filterChoices.forEach { (button) in
            button.isHidden = !button.isHidden }
    }
    
    
    @IBAction func filterChoicesTapped(_ sender: UIButton) {
    }
    
    func fetchPhotos() {
        self.db.collection("users").document(userUid!).addSnapshotListener{snapshot, error in
            if let document = snapshot, document.exists {
                guard let data = document.data() else { return }
                self.ownedPhotosUid = data["ownedPhotos"] as! [String]
                self.ownedVideoUid = data["ownedVideos"] as! [String]
            } else {
                print("Document does not exist")
                return
            }
        }
    }
}


