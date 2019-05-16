//
//  ProgressTableViewCellControllerTableViewCell.swift
//  AwesomePhotos
//
//  Created by Rasmus Petersen on 09/05/2019.
//

import UIKit

let progressCapturedKey = "AwesomePhotos.ProgressCaptured"
let thumbnailCapturedKey = "AwesomePhotos.ThumbnailCaptured"


class ProgressTableViewCellControllerTableViewCell: UITableViewCell {
    
    //MARK:- PROPERTIES
    @IBOutlet weak var uploadName: UILabel!
    @IBOutlet weak var progressBarView: UIProgressView!
    
    let progressBarNotification = Notification.Name(rawValue: progressCapturedKey)
    let thumbnailNotification = Notification.Name(rawValue: thumbnailCapturedKey)
    var progressVC = ProgressViewController()
    var cameraVC = CameraViewController()
    lazy var smallId = randomStringWithLength(len: 6)
    var isPaused = false
    
    //MARK:- INITIALIZATION
    override func awakeFromNib() {
        super.awakeFromNib()
        
        progressBarView.layer.cornerRadius = 8
        progressBarView.clipsToBounds = true
        progressBarView.layer.sublayers![1].cornerRadius = 8
        progressBarView.subviews[1].clipsToBounds = true
        
        NotificationCenter.default.addObserver(forName: progressBarNotification,
                                               object: nil,
                                               queue: nil,
                                               using: catchProgressNotification)
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }
    
    //Removes leftover observers
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK:- CUSTOM FUNCTIONS
    
    //1. Populates cells with corresponding datatype
    func populateTableCell(progressCell : Progress){
        
        uploadName.text = progressCell.label
        progressBarView.progress = progressCell.progress
        progressVC.progressCells.append(progressCell)
    }
    
    
    //3. Catches the current progress of the firebase object currently uploading
    func catchProgressNotification(notification : Notification){
        
        guard let progress = notification.userInfo as? [String : Float] else { return }
        for (key, value) in progress {
            progressBarView.setProgress(value, animated: true)
            if key == "IMG"{
                uploadName.text = "IMG_\(smallId).JPG" as String
            }
            else{
                uploadName.text = "VID_\(smallId).MOV" as String
            }
        }
    }
    
    //4. Generates random string for the name of the media. Used in 3. method
    func randomStringWithLength(len: Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for _ in 1...len{
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        return randomString
    }
}

class Progress {
    
    var label : String
    var progress : Float
    
    init(label : String, progress : Float) {
        self.label = label
        self.progress = progress
    }
}
