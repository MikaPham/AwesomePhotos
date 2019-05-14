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
    let userEmail = Auth.auth().currentUser?.email
    
    var owners = [User]()
    var noWm = [User]()
    var wm = [User]()
    var toBeRemovedOwners = [User]()
    var toBeRemovedNoWm = [User]()
    var toBeRemovedWm = [User]()
    var photoUid: String?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:#selector(handleRefresh),for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.mainRed()
        
        return refreshControl
    }()
    
    //MARK: UI
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch permissionSelector.selectedSegmentIndex {
            case 0:
                return owners.count
            case 1:
                return noWm.count
            case 2:
                return wm.count
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "email", for: indexPath) as! CellWithButton
        switch permissionSelector.selectedSegmentIndex {
            case 0:
                cell.button.isHidden = false
                cell.cellLabel?.text = owners[indexPath.row].email
                if owners[indexPath.row].email == userEmail {
                    cell.button.isHidden = true
                }
                break
            case 1:
                cell.button.isHidden = false
                cell.cellLabel?.text = noWm[indexPath.row].email
                break
            case 2:
                cell.button.isHidden = false
                cell.cellLabel?.text = wm[indexPath.row].email
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
        self.usersTableView.addSubview(refreshControl)
        fetchOwnersAndViewers()
        configureDoneButton()
        configureNavBar(title: "Edit permission")
        permissionSelector.selectedSegmentIndex = 0
    }
    
    //MARK: Selectors
    @objc func onDoneTapped() {
        var ownersUid = [String]()
        toBeRemovedOwners.forEach{(user) in
            guard let uid = user.uid else { return }
            ownersUid.append(uid)
        }
        var noWmUid = [String]()
        toBeRemovedNoWm.forEach{(user) in
            guard let uid = user.uid else { return }
            noWmUid.append(uid)
        }
        var wmUid = [String]()
        toBeRemovedWm.forEach{(user) in
            guard let uid = user.uid else { return }
            wmUid.append(uid)
        }
        self.db.collection("photos").document(photoUid!).updateData(
        ["owners" : FieldValue.arrayRemove(ownersUid), "sharedWith": FieldValue.arrayRemove(noWmUid), "sharedWM": FieldValue.arrayRemove(wmUid)]
        )
        navigationItem.rightBarButtonItem?.isEnabled = false
        cleanUsersArrays()
        self.present(AlertService.basicAlert(imgName: "WinkFace", title: "Done!", message: "The permission for this photo has been updated."), animated: true, completion: nil)
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
                toBeRemovedNoWm.append(noWm[button.tag])
                noWm.remove(at: noWm.firstIndex(of: noWm[button.tag])!)
                break
            case 2:
                toBeRemovedWm.append(wm[button.tag])
                wm.remove(at: wm.firstIndex(of: wm[button.tag])!)
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
    
    // Refresh control
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.usersTableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    //MARK: API
    fileprivate func cleanUsersArrays() {
        self.toBeRemovedOwners.removeAll()
        self.toBeRemovedNoWm.removeAll()
        self.toBeRemovedWm.removeAll()
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
        self.db.collection("photos").document(photoUid!).getDocument{document, error in
            if let document = document, document.exists {
                guard let data = document.data() else { return }
                for viewerUid in data["sharedWith"] as! [String] {
                    self.noWm.append(self.getUsersByUid(viewerUid))
                }
                for ownerUid in data["owners"] as! [String] {
                    self.owners.append(self.getUsersByUid(ownerUid))
                }
                for wmUid in data["sharedWM"] as! [String] {
                    self.wm.append(self.getUsersByUid(wmUid))
                }
//                DispatchQueue.main.async() {
//                    self.usersTableView.reloadData()
//                }

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


            
        



