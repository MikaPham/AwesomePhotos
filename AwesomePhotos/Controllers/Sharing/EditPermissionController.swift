//
//  EditPermissionController.swift
//  AwesomePhotos
//
//  Created by Apple on 4/30/19.
//

import UIKit
import Firebase

class EditPermissionController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var permissionSelector: UISegmentedControl!
    @IBOutlet weak var usersTableView: UITableView!
    
    let db = Firestore.firestore() 
    
    var owners = [User]()
    var viewers = [User]()
    var toBeRemovedOwners = [User]()
    var toBeRemovedViewers = [User]()
    var photoUid = "testphoto2"
    
    //MARK: UI
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch permissionSelector.selectedSegmentIndex {
            case 0:
                return owners.count
            case 1:
                return viewers.count
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "email", for: indexPath) as! CellWithButton
        switch permissionSelector.selectedSegmentIndex {
            case 0:
                cell.cellLabel?.text = owners[indexPath.row].email
                break
            case 1:
                cell.cellLabel?.text = viewers[indexPath.row].email
                break
            default:
                break
        }
        cell.button.tag = indexPath.row
        cell.button.indexPath = indexPath
        cell.button.addTarget(self, action: #selector(removeTapped), for: .touchUpInside)
        return cell
    }
    
    fileprivate func configureDoneButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(onDoneTapped))
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.tintColor = UIColor.mainRed()
    }
    
    //MARK: Init
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchOwnersAndViewers()
        configureDoneButton()
        configureNavBar(title: "Edit permission")
    }
    
    //MARK: Selectors
    @objc func onDoneTapped() {
        var ownersUid = [String]()
        toBeRemovedOwners.forEach{(user) in
            guard let uid = user.uid else { return }
            ownersUid.append(uid)
        }
        var viewersUid = [String]()
        toBeRemovedViewers.forEach{(user) in
            guard let uid = user.uid else { return }
            viewersUid.append(uid)
        }
        self.db.collection("photos").document(photoUid).updateData(
            ["owners" : FieldValue.arrayRemove(ownersUid), "sharedWith": FieldValue.arrayRemove(viewersUid)]
        )
        navigationItem.rightBarButtonItem?.isEnabled = false
        cleanUsersArrays()
    }
    
    @objc func removeTapped(sender:cellButton!) {
        guard let button = sender else { return }
        guard let indexPath = button.indexPath else { return }
        
        switch permissionSelector.selectedSegmentIndex {
            case 0:
                toBeRemovedOwners.append(owners[button.tag])
                owners.remove(at: owners.firstIndex(of: owners[button.tag])!)
                break
            case 1:
                toBeRemovedViewers.append(viewers[button.tag])
                viewers.remove(at: viewers.firstIndex(of: viewers[button.tag])!)
                break
            default:
                break
        }
        self.usersTableView.deleteRows(at: [indexPath], with: .fade)
        self.usersTableView.reloadData()
        if(navigationItem.rightBarButtonItem?.isEnabled == false) {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        self.usersTableView.reloadData()
    }
    
    //MARK: API
    fileprivate func cleanUsersArrays() {
        self.toBeRemovedOwners.removeAll()
        self.toBeRemovedViewers.removeAll()
    }
    
    fileprivate func getUsersByUid(_ viewerUid: String) -> User {
        let user = User()
        self.db.collection("users").document(viewerUid).getDocument{document ,error in
            if let userDoc = document, userDoc.exists {
                guard let userData = userDoc.data() else { return }
                print(userData)
                user.setValuesForKeys(userData)
                user.uid = viewerUid
            }
        }
        return user
    }
    
    fileprivate func fetchOwnersAndViewers() {
        self.db.collection("photos").document(photoUid).getDocument{document, error in
            if let document = document, document.exists {
                guard let data = document.data() else { return }
                for viewerUid in data["sharedWith"] as! [String] {
                    self.viewers.append(self.getUsersByUid(viewerUid))
                }
                for ownerUid in data["owners"] as! [String] {
                    self.owners.append(self.getUsersByUid(ownerUid))
                }
            } else {
                print("Document does not exist")
                return
            }
        }
        //Must have this or else arrays will be empty
        DispatchQueue.main.async() {
            self.usersTableView.reloadData()
        }
    }
}


            
        



