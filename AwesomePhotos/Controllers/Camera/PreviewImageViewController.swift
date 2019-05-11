import Foundation
import UIKit
import FirebaseStorage
import Firebase


protocol UploadImageDelegate: class {
    func uploadImage()
}

class PreviewmageViewController : UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var photo: UIImageView!
    var image : UIImage!
    var wmImage: UIImage!
    let userUid = Auth.auth().currentUser?.uid
    let userEmail = Auth.auth().currentUser?.email
    weak var delegate: UploadImageDelegate! = nil
    
    //MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        photo.image = self.image
    }
    
    // Hide statusBar
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    //MARK: - Methods
    
    //1. Uploads the taken photo to Firebase Storage
    @IBAction func uploadToStorageButtonPressed(_ sender: UIButton) {
        self.delegate?.uploadImage()
        print("Uploading to Storage")
    }
    
    //2. Saves the photo to local storage
    @IBAction func saveToLocalStorageButtonPressed(_ sender: UIButton) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        print("Saving to Local")
    }
    
    //3. Returns the users to the camera

    @IBAction func discardButtonPressed(_ sender: UIButton) {
        print("Discarded")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backToCamera(_ sender: UIButton) {
        print("Returning to Camera")
        dismiss(animated: true, completion: nil)
    }
}


//!! Tracks progress of image uplaoding -- might be used for later 
//            uploadTask.observe(.progress){ (snapshot) in
//                print(snapshot.progress ?? "Progress cancelled")
//            }
//            uploadTask.resume()
//            dismiss(animated: true, completion: nil)
//       }
