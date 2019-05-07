//
//  TabBarController.swift
//  AwesomePhotos
//
//  Created by User on 5/3/19.
//

import UIKit
import Firebase

class TabBarController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    

    @IBOutlet weak var libraryCollectionView: UICollectionView!
    @IBOutlet weak var mySegmentedControl: UISegmentedControl!
    
//    let db = Firestore.firestore()
//    let userUid = Auth.auth().currentUser?.uid
//    var ownedPhotosPaths: [String] = []
    
    var dataArray = [
        ["2", "2", "3", "3", "2", "2", "3", "2", "3", "3", "2", "2", "3", "2", "3", "3", "2", "2" ],
        ["2"]
    ]
    
    var p: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        p = 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray[p].count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! LibraryCollectionViewCell
        cell.myImage.image = UIImage(named: dataArray[p][indexPath.row])
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
        p = sender.selectedSegmentIndex
        libraryCollectionView.reloadData()
    }
    
    @IBOutlet var filterChoices: [UIButton]!
    
    @IBAction func filterAction(_ sender: UIButton) {
        filterChoices.forEach { (button) in
            button.isHidden = !button.isHidden }
    }
    
    
    @IBAction func filterChoicesTapped(_ sender: UIButton) {
    }
    
//    func fetchPhotos() {
//        self.db.collection("users").document(userUid!).getDocument{document, error in
//            if let document = document, document.exists {
//                guard let data = document.data() else { return }
//                self.ownedPhotosPaths = data["ownedPhotos"] as! [String]
//                print(self.ownedPhotosPaths)
//            } else {
//                print("Document does not exist")
//                return
//            }
//        }
//    }
    
}

