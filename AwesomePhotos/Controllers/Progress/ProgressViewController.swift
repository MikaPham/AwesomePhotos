//
//  ProgressViewController.swift
//  AwesomePhotos
//
//  Created by Rasmus Petersen on 09/05/2019.
//

import Foundation
import UIKit


class ProgressViewController : UIViewController{
    
    //MARK:- PROPERTIES
    @IBOutlet var tableview: UITableView!
    var preview = PreviewmageViewController()
    var cameraVC = CameraViewController()
    var progressCells = [Progress]()

    //MARK: INITIALIZATION
    override func viewDidLoad(){
        super.viewDidLoad()
        
        createContent()
        tableview.reloadData()
    }
    
    //1. Creates content for cells
    func createContent(){
        let newContent = Progress(label: "Loading...", progress: 0.0)
        progressCells.append(newContent)
    }
}

extension ProgressViewController : UITableViewDelegate, UITableViewDataSource {
    
    //CELLS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return progressCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let uploadView = progressCells[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ProgressTableViewCellControllerTableViewCell
        cell.populateTableCell(progressCell: uploadView)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        
        guard editingStyle == .delete else { return }
        
        progressCells.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic )
    }
    
    
    //HEADERS
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! ProgressHeaderCellView
        return cell.contentView
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! ProgressHeaderCellView
        return cell.bounds.height
    }
}
