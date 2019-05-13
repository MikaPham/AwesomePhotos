//
//  ProgressViewController.swift
//  AwesomePhotos
//
//  Created by Rasmus Petersen on 09/05/2019.
//

import Foundation
import UIKit

class ProgressViewController : UIViewController{
    
    @IBOutlet var tableview: UITableView!
    var progressCell : [Progress] = []
    var preview = PreviewmageViewController()
    var progressTableCell = ProgressTableViewCellControllerTableViewCell()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        progressCell = progressTableCell.createContent()

    }

}

//Removes a soon to be uploaded media from the queue
extension ProgressViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return progressCell.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let uploadView = progressCell[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ProgressTableViewCellControllerTableViewCell
        cell.populateTableCell(progressCell: uploadView)
        return cell
    }
}


