import Foundation
import UIKit
import FirebaseStorage

class PreviewmageViewController : UIViewController
{
    //MARK: - Properties
    @IBOutlet weak var photo: UIImageView!
    var image : UIImage!
    
    let storageReference : StorageReference = {
        return Storage.storage().reference(forURL: "gs://awesomephotos-b794e.appspot.com/").child("photos")
    }()
    
    //MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        photo.image = self.image
    }
    
    //MARK: - Methods
    
    //Uploads the taken photo to Firebase Storage
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
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        dismiss(animated: true, completion: nil)
    }
    
    //Returns the users to the camera
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
