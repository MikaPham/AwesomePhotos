import FirebaseStorage
import Foundation
import UIKit
import FirebaseStorage

class DownloadImageViewController : UIViewController {
    
    let storageReference : StorageReference = {
        return Storage.storage().reference(forURL: "gs://awesomephotos-b794e.appspot.com/").child("photos")
    }()
    
    @IBOutlet weak var downloadImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }    
    @IBAction func btnPressed(_ sender: UIButton) {
        downloadImageToPhone()
    }
    func downloadImageToPhone(){
        let downloadReference = storageReference.child("A1287D98-1B57-4518-9B3B-F6C3CC2EF29F.jpg")
        let downloadTask = downloadReference.getData(maxSize: 1024 * 1024 * 12) { (data, error) in
            if let data = data{
                let image = UIImage(data: data)
                self.downloadImage.image = image
            }
            print(error ?? "No error")
        }
        downloadTask.observe(.progress){ (snapshot) in
            print(snapshot.progress ?? "Progress cancelled")
        }
        downloadTask.resume()
    }
}
