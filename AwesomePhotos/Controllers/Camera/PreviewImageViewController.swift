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
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var saveIcon: UIImageView!
    @IBOutlet weak var saveLabel: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var uploadIcon: UIImageView!
    @IBOutlet weak var uploadLbl: UILabel!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var discardIcon: UIImageView!
    @IBOutlet weak var discardLbl: UILabel!
    @IBOutlet weak var discardBtn: UIButton!
    @IBOutlet weak var whiteHomeBG: UILabel!
    
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
    
    var isDismissed = false
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isDismissed == false {
            backBtn.isHidden = true
            saveIcon.isHidden = true
            saveLabel.isHidden = true
            saveBtn.isHidden = true
            uploadIcon.isHidden = true
            uploadLbl.isHidden = true
            uploadBtn.isHidden = true
            discardIcon.isHidden = true
            discardLbl.isHidden = true
            discardBtn.isHidden = true
            whiteHomeBG.isHidden = true
            isDismissed = true
        }
        else{
            backBtn.isHidden = false
            saveIcon.isHidden = false
            saveLabel.isHidden = false
            saveBtn.isHidden = false
            uploadIcon.isHidden = false
            uploadLbl.isHidden = false
            uploadBtn.isHidden = false
            discardIcon.isHidden = false
            discardLbl.isHidden = false
            discardBtn.isHidden = false
            whiteHomeBG.isHidden = false
            isDismissed = false
        }
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
