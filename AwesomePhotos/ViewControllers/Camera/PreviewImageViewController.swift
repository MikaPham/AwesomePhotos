import Foundation
import UIKit
import FirebaseStorage

class PreviewmageViewController : UIViewController
{
    
    @IBOutlet weak var watermarkView: UIImageView!
    @IBOutlet weak var photo: UIImageView!
    var image : UIImage!
    
    let storageReference : StorageReference = {
        return Storage.storage().reference(forURL: "gs://awesomephotos-b794e.appspot.com/").child("photos")
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photo.image = self.image
    }
    
    //Uploads the taken photo to FirebaseStorage
    @IBAction func savePhotoBtnPressed(_ sender: UIButton) {
        let id = UUID()
        guard let imageData = image.jpegData(compressionQuality: 0.55) else { return }
        
        let uploadImageRef = storageReference.child(id.uuidString + ".jpg")
        let uploadTask = uploadImageRef.putData(imageData, metadata : nil) { (metadata, error) in
            print("Upload finished")
        }
        uploadTask.observe(.progress){ (snapshot) in
            print(snapshot.progress ?? "Progress cancelled")
        }
        uploadTask.resume()
        dismiss(animated: true, completion: nil)
    }
    
    //Saves the photo to local storage
    @IBAction func saveToLocalBtnPressed(_ sender: UIButton) {
        
        let waterMarkedImage = UIImage.imageWithWatermark(image1: photo, image2: watermarkView)
        UIImageWriteToSavedPhotosAlbum(waterMarkedImage, nil, nil, nil)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}


