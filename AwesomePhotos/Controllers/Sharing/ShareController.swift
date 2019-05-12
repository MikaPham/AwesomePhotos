//
//  ViewController.swift
//  RxSwiftExample
//
//  Created by Apple on 3/30/19.
//  Copyright © 2019 Minh Quang Pham. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Firebase

class ShareController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var shareTableView: UITableView!
    @IBOutlet weak var permissionSelector: UISegmentedControl!

    let db = Firestore.firestore()
    
    var users = [User]()
    var shownUsers = [User]()
    var toBeShared = [User]()
    var alreadyShared = [String]()
    var alreadyOwned = [String]()
    var alreadySharedWm = [String]()
    var persmission = SharingPermissionConstants.OwnerPermission
    var photoUid = "testphoto3"
    
    // Bag of disposables to release them when view is being deallocated
    var disposeBag = DisposeBag()
    
    //MARK: UI
    fileprivate func configureTableViews() {
        shareTableView.delegate = self
        searchTableView.delegate = self
        searchTableView.dataSource = self
        shareTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView.tag == 1) { //shareTableView
            return toBeShared.count
        } else if (tableView.tag == 2) { //searchTableView
            return shownUsers.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "email", for: indexPath) as! CellWithButton
        if (tableView.tag == 1) { //shareTableView
            cell.cellLabel?.text = toBeShared[indexPath.row].email
            cell.button.tag = indexPath.row
            cell.button.indexPath = indexPath
            cell.button.addTarget(self, action: #selector(removeTapped), for: .touchUpInside)
        } else if (tableView.tag == 2) { //searchTableView
            cell.cellLabel.text = shownUsers[indexPath.row].email
            cell.button.tag = indexPath.row
            cell.button.indexPath = indexPath
            cell.button.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
            cell.button.tintColor = UIColor.mainRed()
        }
        return cell
    }
    
    fileprivate func configureShareButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(onShared))
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.tintColor = UIColor.mainRed()
        UINavigationBar.appearance().tintColor = UIColor.mainRed()
    }

    //MARK: Init
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar(title: "Add people")
        configureTableViews()
        fetchUsers()
        makeObsSearchBar()
        configureShareButton()
    }
    
    
    //MARK: Selectors
    @IBAction func indexChanged(_ sender: Any) {
        switch self.permissionSelector.selectedSegmentIndex
        {
        case 0:
            self.persmission = SharingPermissionConstants.OwnerPermission
        case 1:
            self.persmission = SharingPermissionConstants.NoWmPermission
        case 2:
            self.persmission = SharingPermissionConstants.WmPermission
        default:
            break
        }
    }
    
    @objc func onShared() {
        var usersToShare = [String]()
        for user in toBeShared{
            guard let userUid = user.uid else { return }
            usersToShare.append(userUid)
        }
        
        switch self.persmission {
            case SharingPermissionConstants.OwnerPermission:
                if (self.alreadyOwned.count + usersToShare.count <= Limits.OwnersLimit.rawValue){
                    self.db.collection("photos").document(photoUid).updateData(
                        ["owners" : FieldValue.arrayUnion(usersToShare)]
                    )
                    for uid in usersToShare {
                        self.db.collection("users").document(uid).updateData(
                            ["ownedPhotos":FieldValue.arrayUnion([photoUid])]
                        )
                    }
                }else {
                    let alert = AlertService.basicAlert(imgName: "GrinFace", title: "Only 5 owners allowed", message: "This file has already had \(alreadyOwned.count) users as owners. You can only add \(Limits.OwnersLimit.rawValue-alreadyOwned.count) more.")
                    present(alert, animated: true)
                }
            break
            
            case SharingPermissionConstants.NoWmPermission:
                self.db.collection("photos").document(photoUid).updateData(
                    ["sharedWith" : FieldValue.arrayUnion(usersToShare)]
                )
                for uid in usersToShare {
                    self.db.collection("users").document(uid).updateData(
                        ["sharedPhotos":FieldValue.arrayUnion([photoUid])]
                    )
                }
            break
            
            case SharingPermissionConstants.WmPermission:
                self.db.collection("photos").document(photoUid).updateData(
                    ["sharedWM":FieldValue.arrayUnion(usersToShare)]
                )
                for uid in usersToShare {
                    self.db.collection("users").document(uid).updateData(
                        ["wmPhotos":FieldValue.arrayUnion([photoUid])]
                    )
                }
            break
        }

        toBeShared.removeAll()
        shareTableView.reloadData()
        
        var message: String
        if (self.persmission == SharingPermissionConstants.OwnerPermission) {
            message = "Successfully added selected users as the owners of the file."
        } else if (self.persmission == SharingPermissionConstants.NoWmPermission) {
            message = "Successfully shared the file without watermark to the selected users."
        } else {
            message = "Successfully shared the watermarked file to the selected users."
        }
        let alert = AlertService.basicAlert(imgName: "SmileFace", title: "Share successful", message: message)
        self.present(alert, animated: true)
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        // Re-fetch users
        fetchUsers()
    }
    
    
    @objc func addTapped(sender:cellButton!) {
        guard let button = sender else { return }
        guard let indexPath = button.indexPath else {return }
        if toBeShared.contains(shownUsers[button.tag]) {
            shownUsers.remove(at: button.tag) //remove from shownUsers
            searchTableView.deleteRows(at: [indexPath], with: .top) //remove row from searchTableView
            searchTableView.reloadData() //reload data of searchTableView
            return
        }
        toBeShared.append(shownUsers[button.tag]) //add to toBeShared
        shownUsers.remove(at: button.tag) //remove from shownUsers
        searchTableView.deleteRows(at: [indexPath], with: .top) //remove row from searchTableView
        searchTableView.reloadData() //reload data of searchTableView
        shareTableView.insertRows(at: [NSIndexPath(row: toBeShared.count-1, section: 0) as IndexPath], with: .bottom) //insert row to shareTableView
        shareTableView.scrollToRow(at: NSIndexPath(row: toBeShared.count-1, section: 0) as IndexPath, at: .bottom, animated: true) //scroll to the added row
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    @objc func removeTapped(sender:cellButton!) {
        guard let button = sender else { return }
        guard let indexPath = button.indexPath else { return }

        shownUsers.append(toBeShared[button.tag])
        toBeShared.remove(at: toBeShared.firstIndex(of: toBeShared[button.tag])!) //remove from toBeShared
        
        self.shareTableView.deleteRows(at: [indexPath], with: .fade) //remove row from shareTableView
        self.shareTableView.reloadData() //reload data of shareTableView
        if toBeShared.isEmpty {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        searchTableView.reloadData()
    }
    
    fileprivate func clearUsersLists() {
        self.users.removeAll()
        self.shownUsers.removeAll()
        self.alreadyShared.removeAll()
        
    }
    
    func makeObsSearchBar() {
        self.searchBar
            .rx.text // Observable property from RxCocoa
            .orEmpty // Make it non-optional
            .debounce(.seconds(Int(0.5)), scheduler: MainScheduler.instance) //Wait 0.5s for changes
            .distinctUntilChanged() //If changes didn't occur, check if new value is the same as old value
            .filter { !$0.isEmpty } //If new query is new, make sure it's not empty (so that we don't search on an empty query)
            .subscribe(onNext: {[unowned self] query in // Here we will be notified of every new value
                self.shownUsers = self.users.filter({ (user) -> Bool in
                    (user.email?.contains(query.lowercased()))!
                })
                self.searchTableView.reloadData() // Reload tableview's data
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: API
    func fetchAlreadySharedAndOwned() {
        self.db.collection("photos").document(photoUid).addSnapshotListener{querySnapshot, error in
            guard let data = querySnapshot?.data() else {return}
            self.alreadyShared = data["sharedWith"] as! [String]
            self.alreadyOwned = data["owners"] as! [String]
            self.alreadySharedWm = data["sharedWM"] as! [String]
            
            if(self.alreadyOwned.count == Limits.OwnersLimit.rawValue) {
                self.permissionSelector.setEnabled(false, forSegmentAt: 0)
                self.permissionSelector.selectedSegmentIndex = 1
                self.persmission = SharingPermissionConstants.NoWmPermission
            }
            
            for user in self.users {
                guard let userUid = user.uid else { return }
                if self.alreadyShared.contains(userUid) {
                    self.users.remove(at: self.users.firstIndex(of: user)!)
                }
                else if self.alreadyOwned.contains(userUid) {
                    self.users.remove(at: self.users.firstIndex(of: user)!)
                }
                else if self.alreadyOwned.contains(userUid) {
                    self.users.remove(at: self.users.firstIndex(of: user)!)
                }
            }
        }
    }
    
    func fetchUsers() {
        //Make a connection to the database and take a snapshot at "users" collection
        self.db.collection("users").addSnapshotListener{ querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print ("Error fetching documents")
                return
            }
            self.clearUsersLists()
            for doc in documents {
                let dict = doc.data()
                let user = User()
                user.setValuesForKeys(dict) //Map dictionary values into User objects
                user.uid = doc.documentID
                self.users.append(user)
                //Must have this or else arrays will be empty
                DispatchQueue.main.async() {
                    self.searchTableView.reloadData()
                }
            }
        }
        fetchAlreadySharedAndOwned()
    }
}


