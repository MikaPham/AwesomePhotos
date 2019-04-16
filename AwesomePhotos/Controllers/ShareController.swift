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
    var persmission = AppConstants.OwnerPermission
    
    //var photoUid: String
    
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
            cell.button.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        }
        return cell
    }
    
    
    //MARK: Init
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableViews()
        fetchUsers()
        fetchAlreadyShared()
        makeObsSearchBar()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(onShared))
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.tintColor = UIColor.mainRed()
        navigationItem.title = "Add People"
        UINavigationBar.appearance().tintColor = UIColor.mainRed()
    }
    

    
    //MARK: Selectors
    @IBAction func indexChanged(_ sender: Any) {
        switch self.permissionSelector.selectedSegmentIndex
        {
        case 0:
            self.persmission = AppConstants.OwnerPermission
        case 1:
            self.persmission = AppConstants.ViewerPermission
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
        if (self.persmission == AppConstants.OwnerPermission) {
            self.db.collection("photos").document("abcd").updateData(
                ["owners" : FieldValue.arrayUnion(usersToShare)]
            )
        } else {
            self.db.collection("photos").document("abcd").updateData(
                ["sharedWith" : FieldValue.arrayUnion(usersToShare)]
            )
        }
        toBeShared.removeAll()
        shareTableView.reloadData()
        
        let alert = UIAlertController(title: "Share Successful!", message: "Shared to selected users.", preferredStyle: .alert)
        self.present(alert, animated: true, completion:{
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertClose)))
        })
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    @objc func alertClose(gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func shareTapped(sender:cellButton!) {
        guard let button = sender else { return }
        guard let indexPath = button.indexPath else { return }
    
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
    }
    
    func makeObsSearchBar() {
        self.searchBar
            .rx.text // Observable property from RxCocoa
            .orEmpty // Make it non-optional
            .debounce(0.5, scheduler: MainScheduler.instance) //Wait 0.5s for changes
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
    func fetchAlreadyShared() {
        self.db.collection("photos").document("abcd").addSnapshotListener{querySnapshot, error in
            guard let data = querySnapshot?.data() else {return}
            self.alreadyShared = data["sharedWith"] as! [String]
            for user in self.users {
                guard let userUid = user.uid else { return }
                if self.alreadyShared.contains(userUid) {
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
    }
}


