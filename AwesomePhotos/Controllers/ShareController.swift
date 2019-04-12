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

class ShareController: UITableViewController {
    
    //MARK: UI
    @IBOutlet var searchBar: UISearchBar!
    
    let db = Firestore.firestore()
    
    
    var users = [User]()
    var usersEmails = [String]()
    var shownUsers = [String]()
    var toBeShared = [String]()
    
    var disposeBag = DisposeBag() // Bag of disposables to release them when view is being deallocated

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUsers()
        makeObsSearchBar()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shownUsers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "email", for: indexPath) as! CellWithButton
        cell.textLabel?.text = shownUsers[indexPath.row]
        cell.shareButton.tag = indexPath.row
        cell.shareButton.indexPath = indexPath
        cell.shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        
        return cell
    }
    
    @objc func shareTapped(sender:cellButton!) {
        guard let button = sender else { return }
        guard let indexPath = button.indexPath else { return }
        if !toBeShared.contains(shownUsers[button.tag]) {
            toBeShared.append(shownUsers[button.tag])
            usersEmails.remove(at: usersEmails.firstIndex(of: shownUsers[button.tag])!)
            shownUsers.remove(at: button.tag)
            self.tableView.deleteRows(at: [indexPath], with: .top)
        }
        print(toBeShared,usersEmails)
    }
    
    fileprivate func clearUsersLists() {
        self.usersEmails.removeAll()
        self.users.removeAll()
        self.shownUsers.removeAll()
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
                self.users.append(user)
                if let userEmail = user.email {
                    self.usersEmails.append(userEmail)
                }
                //Must have this or else arrays will be empty
                DispatchQueue.main.async() {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    func makeObsSearchBar() {
        self.searchBar
            .rx.text // Observable property from RxCocoa
            .orEmpty // Make it non-optional
            .debounce(0.5, scheduler: MainScheduler.instance) //Wait 0.5s for changes
            .distinctUntilChanged() //If changes didn't occur, check if new value is the same as old value
            .filter { !$0.isEmpty } //If new query is new, make sure it's not empty (so that we don't search on an empty query)
            .subscribe(onNext: {[unowned self] query in // Here we will be notified of every new value
                self.shownUsers = self.usersEmails.filter{ $0.hasPrefix(query.lowercased()) } // We now do our "API Request" to find cities.
                self.tableView.reloadData() // Reload tableview's data
            })
            .disposed(by: disposeBag)
    }
}


