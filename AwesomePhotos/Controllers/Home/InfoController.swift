//
//  InfoController.swift
//  AwesomePhotos
//
//  Created by Apple on 5/15/19.
//

import UIKit
import Firebase

class InfoController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var imgView: UIImageView!
    
    var titleArray = ["Name","Size","Original resolution","Location","Owned content"]
    var infoArray = [String]()
    var selectedImage: UIImage?
    
    @IBOutlet weak var infoTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar(title: "Info")
        setupNavigationBarItems()
        imgView.image = selectedImage
        navigationController?.hidesBarsOnTap = false
    }
    
    func setupNavigationBarItems(){
        // Configure and assign settingsButton into Nav bar
        let backButton = UIButton(type: .system)
        backButton.setTitle("          ", for: .normal)
        backButton.setImage(#imageLiteral(resourceName: "Path"), for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.tintColor = .mainRed()
        
        backButton.addTarget(self, action: #selector(OwnedImageViewController.goBack), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem?.tintColor = UIColor.mainRed()
    }
    
    @objc func goBack(){
        navigationController?.popViewController(animated: true)
        navigationController?.hidesBarsOnTap = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.infoTableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
        cell.textLabel?.text = titleArray[indexPath.row]
        cell.detailTextLabel?.text = infoArray[indexPath.row]
        return cell
    }
}
