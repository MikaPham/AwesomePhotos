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
    
    var titleArray = ["Name","Size","Time created","MD5 hash","Owned content"]
    var infoArray = [String]()
    var selectedImage: UIImage?
    
    @IBOutlet weak var infoTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar(title: "")
        imgView.image = selectedImage
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
