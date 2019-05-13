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
    
    @IBOutlet weak var abortButton: UIButton!
    @IBOutlet weak var uploadName: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView?
    @IBOutlet weak var progressBarView: UIProgressView!
    
    let progressBarNotification = Notification.Name(rawValue: progressCapturedKey)
    let thumbnailNotification = Notification.Name(rawValue: thumbnailCapturedKey)
    
    var preview = PreviewmageViewController()
    lazy var smallId = randomStringWithLength(len: 6)
    
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
        
        
        NotificationCenter.default.addObserver(forName: thumbnailNotification,
                                               object: nil,
                                               queue: nil)
        { (notification) in
            let preview = notification.object as! PreviewmageViewController
            self.thumbnailImage?.image = preview.photo.image
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //Removes leftover observers
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func populateTableCell(progressCell : Progress){
        uploadName.text = progressCell.label
        progressBarView.progress = Float(progressCell.progress)
        thumbnailImage?.image = progressCell.image
    }
    
    
    func catchProgressNotification(notification:Notification){
        
        uploadName.text = "IMG_\(smallId).JPG" as String
        
        guard let progress = notification.userInfo as? [String : Float] else { return }
        for (value) in progress.values {
            progressBarView.setProgress(value, animated: true)
        }
    }

    
    func createContent() -> [Progress]{
        var arr : [Progress] = []
        let newContent = Progress(image: thumbnailImage!.image!, label: "ImageUpload.JPG", progress: 0)
        
        arr.append(newContent)
        
        return arr
    }
    
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




struct Progress {
    
    var image : UIImage
    var label : String
    var progress : Double
    init(image : UIImage, label : String, progress : Double) {
        self.image = image
        self.label = label
        self.progress = progress
    }
}
