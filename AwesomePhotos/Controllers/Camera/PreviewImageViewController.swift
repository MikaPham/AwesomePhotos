import Foundation
import UIKit
import FirebaseStorage
import Firebase


protocol UploadImageDelegate: class {
    func uploadImage()
    func printNumber()
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
        print (delegate as Any)
        self.delegate?.printNumber()
        photo.image = self.image
    }
    
    //MARK: - Methods
    
    //1. Uploads the taken photo to Firebase Storage
    @IBAction func uploadToStorageButtonPressed(_ sender: UIButton) {
        print ("Pressing Upload")
            self.delegate?.uploadImage()
    }
    
    //2. Saves the photo to local storage
    @IBAction func saveToLocalStorageButtonPressed(_ sender: UIButton) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        dismiss(animated: true, completion: nil)
    }
    
    //3. Returns the users to the camera
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
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
